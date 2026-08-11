#!/usr/bin/env python3
"""PreToolUse deny for $TMPDIR references in Bash commands.

$TMPDIR is not consistently exposed across sandboxed and unsandboxed shells or
background tasks (claude-code #63313, #15700, #78687), while /tmp/claude sits
on the sandbox write allowlist and works in every mode. A SessionStart hook
creates that directory.
"""

import json
import re
import sys

_TMPDIR_RE = re.compile(r"\$\{?TMPDIR\b")

_REASON = ("$TMPDIR is not reliably exposed across sandboxed and unsandboxed "
           "shells; put temp files under /tmp/claude")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return
    if payload.get("tool_name") != "Bash":
        return
    command = (payload.get("tool_input") or {}).get("command") or ""
    if not _TMPDIR_RE.search(command):
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": _REASON,
        }
    }))


main()
