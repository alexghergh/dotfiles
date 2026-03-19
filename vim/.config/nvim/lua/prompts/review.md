---
name: Code Review
interaction: chat
description: Review current changes or specified files using the structured review skill.
opts:
  alias: review
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Use the `review` skill to review the current changes.

Determine the review scope first: current diff, staged changes, current branch, or files I provide. If the target is unclear, ask before reviewing.

Focus on correctness, regressions, maintainability, architecture, and missing tests. Return findings first, ordered by severity, with file references. If no findings are discovered, say so explicitly, then list any open questions or assumptions, followed by a brief summary. Do not implement fixes unless I explicitly ask.
