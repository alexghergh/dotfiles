#!/usr/bin/env python3
"""PreToolUse hook: deny edit tool calls that introduce non-ascii
characters. Reads the hook payload on stdin; prints a deny decision on
offense, prints nothing when the edit is clean. Serves both Claude Code
(Edit/Write/NotebookEdit) and Codex CLI (apply_patch); the deny output
below is the shared wire format both harnesses parse."""
import json
import sys

data = json.load(sys.stdin)
tool_input = data.get("tool_input") or {}
if data.get("tool_name") == "apply_patch":
    # codex: tool_input is {"command": "<apply_patch envelope>"}; scan only
    # added lines (leading `+`) so pre-existing non-ascii in context and
    # deletion lines does not trip the check; line numbers are
    # patch-relative, not file-relative
    patch = tool_input.get("command") or ""
    lines = [line[1:] for line in patch.splitlines() if line.startswith("+")]
else:
    # claude: Edit -> new_string, Write -> content, NotebookEdit -> new_source
    text = tool_input.get("new_string") or tool_input.get("content") or tool_input.get("new_source") or ""
    lines = text.splitlines()

offenses = []
for lineno, line in enumerate(lines, 1):
    bad = sorted({ch for ch in line if ord(ch) > 127})
    if bad:
        offenses.append(f"line {lineno}: " + " ".join(f"{ch!r} (U+{ord(ch):04X})" for ch in bad))

if offenses:
    shown = offenses[:5]
    if len(offenses) > 5:
        shown.append(f"and {len(offenses) - 5} more lines")
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "ascii-only rule: the proposed edit introduces non-ascii characters. "
                + "; ".join(shown)
                + ". rewrite with ascii equivalents (`-`, `'`, `\"`, `->`, `...`) and retry."
            ),
        }
    }))
