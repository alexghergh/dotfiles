---
name: Document Code
interaction: chat
description: Document the files you just changed as a final cleanup pass.
opts:
  alias: document-code
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Switch from implementation to documentation viewpoint for the files you just changed.

Determine the changed-file scope from the current diff or current session context. If that scope is unclear, re-clarify before editing anything.

Limit documentation edits to those files. Improve docstrings, comments, and inline documentation for public interfaces, non-obvious logic, invariants, assumptions, and side effects you might've missed while coding. Match the surrounding code's comment style. Keep edits minimal. Do not expand into repo-wide documentation unless I explicitly ask.
