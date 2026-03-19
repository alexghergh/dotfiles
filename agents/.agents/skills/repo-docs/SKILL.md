---
name: repo-docs
description: Plan, create, or update repository-level documentation such as README.md, ARCHITECTURE.md, AGENTS.md, and related project docs. Use when the user wants repo docs scoped by detail level, wants guidance on which docs belong in a project, or wants existing repo docs improved.
---

# Repository Docs

Use this skill when the user wants repository-level documentation planned, created, updated, or reviewed.

## Workflow

1. Inspect the current repository docs first. Look for `README.md`, `ARCHITECTURE.md`, `AGENTS.md`, and other top-level docs.
2. Present documentation levels before editing. See [doc levels](references/doc-levels.md).
3. Default to high-level + mid-level docs. Treat low-level function or module documentation as out of scope unless the user explicitly asks. Use code-focused documentation for that.
4. Confirm file scope before editing:
   - ask which doc files are in scope
   - for each relevant file, ask whether to create, modify, or leave it alone
   - if `README.md`, `ARCHITECTURE.md`, or `AGENTS.md` is missing, mention it and ask whether the user wants it
   - ask whether to preserve the current style and structure or whether a larger rewrite is allowed
5. Recommend one file mapping based on the requested detail level. See [file selection](references/file-selection.md).
6. Only after scope is confirmed, inspect the code paths needed to support those docs and update the selected files.
7. If the user says "too detailed" or "not detailed enough", recalibrate the level and revise accordingly.

## Default file roles

- `README.md`: high-level project entry point. See [README guidance](references/readme-guidance.md).
- `ARCHITECTURE.md`: mid-level design, component boundaries, pipelines, contracts, and diagrams. See [ARCHITECTURE guidance](references/architecture-guidance.md).
- `AGENTS.md`: repo-specific workflow and guardrails for contributors or agents. This is not general product documentation. See [AGENTS guidance](references/agents-guidance.md).

## Other docs

If the repo shape suggests they matter, consider asking about:
- `CONTRIBUTING.md`
- `SECURITY.md`
- `DEPLOYMENT.md`
- `SUPPORT.md`

Do not assume these files are needed. Ask first.

## Style rules

- respect the current style and structure of existing docs unless the user approves a larger rewrite
- do not create doc files just because they are common; create them only after the user confirms they are in scope
- keep repo docs focused on repo-level concerns, not line-by-line code explanation
- load only the specific guidance or example files you need

## References

- [doc levels](references/doc-levels.md)
- [file selection](references/file-selection.md)
- [README guidance](references/readme-guidance.md)
- [ARCHITECTURE guidance](references/architecture-guidance.md)
- [AGENTS guidance](references/agents-guidance.md)
- examples:
  - [README good](references/example-readme-good.md)
  - [README bad](references/example-readme-bad.md)
  - [ARCHITECTURE good](references/example-architecture-good.md)
  - [ARCHITECTURE bad](references/example-architecture-bad.md)
  - [AGENTS good](references/example-agents-good.md)
  - [AGENTS bad](references/example-agents-bad.md)
