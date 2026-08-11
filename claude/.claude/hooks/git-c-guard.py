#!/usr/bin/env python3
"""PreToolUse deny for `git -C` in Bash commands.

`git -C <path>` matches no allow rule in settings.json and always prompts, so
the plain cwd forms stay the only approved way to reach a repo.

The match is textual: a command that merely quotes the string, such as
`grep 'git -C' file`, is denied too. Use the Grep tool for that, which the
command discipline already prefers.
"""

import json
import re
import sys

_GIT_C_RE = re.compile(r"\bgit\s+-C")

_REASON = ("git -C matches no allow rule and always prompts; run git from the "
           "repo cwd instead")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return
    if payload.get("tool_name") != "Bash":
        return
    command = (payload.get("tool_input") or {}).get("command") or ""
    if not _GIT_C_RE.search(command):
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": _REASON,
        }
    }))


main()
