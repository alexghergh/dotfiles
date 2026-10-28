"""Read the remaining Claude Code and Codex usage limits from their usage APIs.

Each fetch reads the access token the CLI itself keeps on disk
(`~/.claude/.credentials.json`, `~/.codex/auth.json`), sends it with one request
and then drops it. Tokens are never written, logged or refreshed: refresh tokens
are single-use, so refreshing here would race the CLI and can sign it out. An
expired token is reported as such; running the CLI once renews it.

Neither endpoint is a published API; the shapes below follow what the CLIs and
other usage monitors (e.g. github.com/vinzdg/codenotch) read.

Run directly to print the parsed limits: `python3 usage.py`
"""

import base64
import json
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

CLAUDE_CREDENTIALS = Path.home() / ".claude" / ".credentials.json"
CLAUDE_URL = "https://api.anthropic.com/api/oauth/usage"

CODEX_AUTH = Path.home() / ".codex" / "auth.json"
CODEX_URL = "https://chatgpt.com/backend-api/wham/usage"


@dataclass
class Window:
    name: str  # "5h", "Weekly", ...
    left: float  # percent left, 0-100
    resets_at: float | None  # epoch seconds


@dataclass
class Usage:
    windows: list[Window] = field(default_factory=list)
    # set when the fetch failed: 'auth' (signed out or token expired), 'rate_limited'
    # (asked too often; keep the last numbers), or 'unreachable' (anything else)
    error_kind: str | None = None
    error: str | None = None
    retry_after: float | None = None  # seconds, for 'rate_limited'


class UsageError(Exception):
    def __init__(self, kind, message, retry_after=None):
        super().__init__(message)
        self.kind = kind
        self.retry_after = retry_after


def _get(url, headers):
    request = urllib.request.Request(
        url, headers={"Accept": "application/json", **headers}
    )
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            return json.load(response)
    except urllib.error.HTTPError as e:
        if e.code in (401, 403):
            raise UsageError("auth", f"Sign-in rejected (HTTP {e.code})") from None
        if e.code == 429:
            retry_after = e.headers.get("Retry-After")
            raise UsageError(
                "rate_limited",
                "Asked too often (HTTP 429)",
                float(retry_after) if retry_after and retry_after.isdigit() else None,
            ) from None
        raise UsageError(
            "unreachable", f"Usage API unreachable: HTTP {e.code}"
        ) from None
    except (urllib.error.URLError, TimeoutError) as e:
        reason = getattr(e, "reason", e)
        raise UsageError("unreachable", f"Usage API unreachable: {reason}") from None
    except json.JSONDecodeError:
        raise UsageError("unreachable", "Usage API sent an unexpected reply") from None


def _window_name(seconds):
    if not seconds:
        return "Limit"
    hours = seconds / 3600
    if hours <= 24:
        return f"{round(hours)}h"
    if 6 * 24 <= hours <= 8 * 24:
        return "Weekly"
    return f"{round(hours / 24)}d"


def _jwt_expiry(token):
    """The `exp` claim of a JWT, in epoch seconds, or None when it can't be read."""
    try:
        payload = token.split(".")[1]
        payload += "=" * (-len(payload) % 4)
        return json.loads(base64.urlsafe_b64decode(payload)).get("exp")
    except (IndexError, ValueError):
        return None


def _iso_time(text):
    return datetime.fromisoformat(text).timestamp() if text else None


def claude():
    """Claude Code's windows: 5h, weekly, and any per-model weekly ones (e.g.
    "Weekly Fable")."""
    try:
        oauth = json.loads(CLAUDE_CREDENTIALS.read_text())["claudeAiOauth"]
        token, expires_ms = oauth["accessToken"], oauth.get("expiresAt")
    except (OSError, ValueError, KeyError):
        raise UsageError("auth", "Not signed in to Claude Code") from None
    if expires_ms and expires_ms / 1000 < time.time():
        raise UsageError("auth", "Sign-in expired; run claude once to renew it")

    data = _get(
        CLAUDE_URL,
        {"Authorization": f"Bearer {token}", "anthropic-beta": "oauth-2025-04-20"},
    )

    # `limits` is the list Claude Code's /usage shows: `{kind, group, percent
    # (used), resets_at, scope}`, where a per-model window names its model in
    # `scope.model.display_name`
    windows = []
    kinds = set()
    for entry in data.get("limits") or []:
        if entry.get("percent") is None:
            continue
        group = entry.get("group") or ""
        name = {"session": "5h", "weekly": "Weekly"}.get(group, group.title())
        model = ((entry.get("scope") or {}).get("model") or {}).get("display_name")
        windows.append(
            Window(
                f"{name} {model}" if model else name,
                max(0.0, 100 - entry["percent"]),
                _iso_time(entry.get("resets_at")),
            )
        )
        kinds.add(entry.get("kind"))

    # an entry drops out of `limits` right after its window resets, while the older
    # `five_hour` / `seven_day` fields keep reporting it
    for kind, key, name in (
        ("session", "five_hour", "5h"),
        ("weekly_all", "seven_day", "Weekly"),
    ):
        w = data.get(key)
        if kind in kinds or not isinstance(w, dict) or w.get("utilization") is None:
            continue
        windows.append(
            Window(
                name, max(0.0, 100 - w["utilization"]), _iso_time(w.get("resets_at"))
            )
        )

    windows.sort(key=lambda w: {"5h": 0, "Weekly": 1}.get(w.name, 2))
    return windows


def codex():
    """Codex's windows; which ones exist depends on the plan (some have no 5h window)."""
    try:
        tokens = json.loads(CODEX_AUTH.read_text())["tokens"]
        token, account_id = tokens["access_token"], tokens["account_id"]
    except (OSError, ValueError, KeyError):
        raise UsageError("auth", "Not signed in to Codex") from None
    expires = _jwt_expiry(token)
    if expires and expires < time.time():
        raise UsageError("auth", "Sign-in expired; run codex once to renew it")

    data = _get(
        CODEX_URL,
        {"Authorization": f"Bearer {token}", "ChatGPT-Account-Id": account_id},
    )

    # the main limit, then per-feature ones, each with up to two windows of the
    # same shape; the extra ones are named after their limit, e.g. "Weekly Code
    # review"
    windows = _codex_windows(data.get("rate_limit"))
    for extra in data.get("additional_rate_limits") or []:
        label = extra.get("limit_name") or extra.get("metered_feature") or ""
        windows += _codex_windows(extra.get("rate_limit"), label)
    windows += _codex_windows(data.get("code_review_rate_limit"), "Code review")
    return windows


def _codex_windows(limit, label=""):
    windows = []
    for key in ("primary_window", "secondary_window"):
        w = (limit or {}).get(key)
        if not isinstance(w, dict) or w.get("used_percent") is None:
            continue
        name = _window_name(w.get("limit_window_seconds"))
        windows.append(
            Window(
                f"{name} {label}" if label else name,
                max(0.0, 100 - w["used_percent"]),
                w.get("reset_at"),
            )
        )
    return windows


def fetch(provider):
    """Run one provider's fetch, turning failures into an error on the result."""
    try:
        return Usage(windows=provider())
    except UsageError as e:
        return Usage(error_kind=e.kind, error=str(e), retry_after=e.retry_after)


if __name__ == "__main__":
    for name, provider in (("Claude", claude), ("Codex", codex)):
        usage = fetch(provider)
        if usage.error:
            print(f"{name}: {usage.error_kind}: {usage.error}")
        for w in usage.windows:
            resets = (
                time.strftime("%a %H:%M", time.localtime(w.resets_at))
                if w.resets_at
                else "-"
            )
            print(f"{name}: {w.name}: {w.left:.0f}% left, resets {resets}")
