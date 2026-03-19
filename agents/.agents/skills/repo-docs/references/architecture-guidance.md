# ARCHITECTURE Guidance

## Purpose

`ARCHITECTURE.md` should explain how the system is put together at a design level. It is the place for boundaries, flows, contracts, and important structural decisions.

## Good content

- major components and responsibilities
- directory or package structure when it reflects design boundaries
- request, job, or data pipelines
- key APIs, contracts, and invariants
- diagrams when they add clarity

## Avoid

- setup steps that belong in `README.md`
- contributor workflow rules that belong in `AGENTS.md` or `CONTRIBUTING.md`
- function-by-function code explanation
- stale aspirational architecture that does not match the codebase

## Existing-style rule

If `ARCHITECTURE.md` already exists, decide with the user whether to preserve the current structure or reshape it more aggressively before editing.

## When to load examples

If the user wants clearer design docs or a restructure, load:
- [ARCHITECTURE good](references/example-architecture-good.md)
- [ARCHITECTURE bad](references/example-architecture-bad.md)
