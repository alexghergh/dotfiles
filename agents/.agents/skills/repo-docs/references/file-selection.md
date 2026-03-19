# File Selection

## Default mapping

- `README.md` -> high-level project entry point
- `ARCHITECTURE.md` -> mid-level design and structure
- `AGENTS.md` -> contributor or agent workflow, commands, testing policy, code style, and guardrails

## When to suggest other docs

- `CONTRIBUTING.md` when contribution flow, branch policy, or review expectations matter
- `SECURITY.md` when security reporting, secrets handling, or vulnerability process matters
- `DEPLOYMENT.md` when release or operational rollout steps are non-trivial
- `SUPPORT.md` when there is a defined support channel or escalation path

Other docs may apply depending on repo shape. Suggest them only when there is a concrete reason.

## Ask-first rules

- if a relevant file is missing, ask whether to create it
- if a relevant file exists, ask whether to preserve its style or allow a larger rewrite
- if the user asks for repo docs generically, propose a file list and level mapping before editing

## Respect the existing shape

- if the repo already uses `docs/`, build on that instead of forcing everything into top-level files
- if there are topic-specific docs already, link or extend them instead of duplicating them
- if low-level code docs are what the user really wants, redirect to code-focused documentation
