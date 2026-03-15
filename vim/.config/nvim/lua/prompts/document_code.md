---
name: Document Code
interaction: chat
description: Add docstrings, comments, and inline documentation to code.
opts:
  alias: document-code
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Add documentation to the code in this project. Add docstrings to functions and modules that lack them, prioritizing public interfaces. Add inline comments for non-obvious logic, algorithms, and invariants. Match the surrounding code's comment style. Do not add boilerplate or obvious comments.
