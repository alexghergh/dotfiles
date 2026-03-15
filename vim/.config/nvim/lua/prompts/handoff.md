---
name: Handoff
interaction: chat
description: Summarize current state, decisions, files touched, open questions, and next steps.
opts:
  alias: handoff
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Summarize the current state of work as a handoff for a fresh session or another developer. Include: what was being done and why, what is done vs in progress vs not started, key decisions and their reasoning, files touched with a one-line description per change, unresolved questions, ordered next steps, and risks.

If I explicitly ask for a file, write it to `handoff-YYYY-MM-DD-<short-title>.md` in the project root. Otherwise, output in chat only.
