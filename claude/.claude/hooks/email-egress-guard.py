#!/usr/bin/env python3
"""PreToolUse deny for the user's email address in shell, web and edit tool
calls.

Agents fill in contact details on their own, e.g. a `User-Agent` or `From`
header for Wikipedia or SEC, whose API policies ask for a contact address. The
address comes from the session context or from git config, and an instruction in
AGENTS.md is only a request the model weighs against the task. Edits are covered
because a script written to disk can carry the address into a request whose
shell command does not contain it.

The match is textual on the whole tool input, whatever the tool; the matcher in
each harness config decides which tools reach this script. The username mail
prefix, or its URL-encoded form, covers every address of the user, including the
GitHub noreply one, without spelling any of them out in this file. An address
read at runtime, such as `$(git config user.email)` inside a `curl` call, is not
caught. Serves both Claude Code and Codex CLI, which share the PreToolUse
payload and deny output shapes.
"""

import json
import re
import sys

_EMAIL_RE = re.compile(r"alexghergh(@|%40)", re.IGNORECASE)

_REASON = ("the call contains the user's email address; never send it to an "
           "outside service or write it into a file; if a command or file "
           "needs it, ask the user to add it")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return
    tool_input = json.dumps(payload.get("tool_input") or {})
    if not _EMAIL_RE.search(tool_input):
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": _REASON,
        }
    }))


main()
