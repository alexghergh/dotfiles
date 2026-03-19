---
name: Document Repository
interaction: chat
description: Plan or update repository-level documentation using the repo-docs skill.
opts:
  alias: document-repo
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Use the `repo-docs` skill to plan or update repository-level documentation.

Start by clarifying documentation scope with me before editing anything:
- default to high-level and mid-level repository docs, not low-level function documentation
- ask which files are in scope and whether each should be created, modified, or left alone
- if `README.md`, `ARCHITECTURE.md`, or `AGENTS.md` is missing, mention it and ask whether I want it
- ask whether to preserve the current style and structure of existing docs or whether a larger rewrite is allowed
- if the repo shape suggests other important docs such as `CONTRIBUTING.md`, `SECURITY.md`, `DEPLOYMENT.md`, or `SUPPORT.md`, ask whether they should be included too
