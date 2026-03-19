# AGENTS Guidance

## Purpose

`AGENTS.md` is a workflow and guardrails file for contributors or coding agents. It is not the main place for product or architecture documentation.

## Good content

- repo-specific commands that matter in practice
- testing or no-testing policy
- code style and editing constraints
- approval, safety, or review expectations
- pointers to important repo docs and local conventions

## Avoid

- repeating the whole README
- deep architecture explanations better suited for `ARCHITECTURE.md`
- generic advice that is not repo-specific
- hidden policy changes without user confirmation

## Existing-style rule

If `AGENTS.md` exists, ask whether to preserve its current structure or rewrite it more aggressively. If it is missing, ask before creating it.

## When to load examples

If the user wants to create or rework `AGENTS.md`, load:
- [AGENTS good](references/example-agents-good.md)
- [AGENTS bad](references/example-agents-bad.md)
