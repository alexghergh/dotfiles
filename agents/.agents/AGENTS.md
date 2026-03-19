## Intent

Prefer the smallest correct code change that fits the existing codebase while implementing the user's intent. When uncertain, ask rather than guess.

Avoid over-engineering. Keep code DRY, but do not invent abstractions early. Reuse existing utility modules when they already fit the problem, and only extract helpers when the logic is clearly reusable across multiple code paths or meaningfully improves clarity.

## Workflow

Read before editing. Explore before planning. Plan before implementing. Scale the process to the change.

A change is trivial when it is clearly scoped, low risk, and localized, for example: editing text in one file, a small obvious adjustment to a function without changing interfaces or external behavior, or renaming/comment updates with no behavioral change.

For trivial changes:
- read the target file and directly touched context
- make the edit directly when the user is clearly asking for that change; treat that request as approval
- if the change turns out to be less trivial than expected, stop and switch to the full workflow below

For non-trivial changes, before planning:
- read the relevant code paths first
- read the documentation relevant to the area you are changing, read local documentation files when present
- ask questions for any non-obvious product or implementation choice until material ambiguities are resolved and the intended change is clear

Before implementing non-trivial changes:
- present a short spec covering the requirements being satisfied, the intended approach, the files you expect to touch, and if present any notable risks or trade-offs
- include architecture and data model details where relevant
- recommend one path with reasoning instead of presenting a large menu of options
- explicitly ask the user to confirm the path forward
- if the change would expand beyond the current scope or affect code paths outside the user's apparent target area, flag it and ask before proceeding
- flag nearby issues separately rather than bundling them in

## Code Style

Match the project's existing style, structure, and conventions.

Do not run CLI formatting or linting tools unless prompted.

Keep implementations simple and direct:
- avoid duplicate logic
- avoid defensive code for unrealistic failure modes just to appear safe
- do not introduce obvious bugs, security issues, race conditions or unnecessary complexity

## Documentation

Respect the project's documentation style. Keep comments consistent with the surrounding file. Default to lowercase comments without trailing punctuation when that fits the local style.

Document functions, modules, and public interfaces in the style the project already uses. Include arguments, return values, side effects, and assumptions when they are not obvious. Prioritize code that is non-trivial, externally used, easy to misuse, or difficult to understand.

Prefer concise comments that explain intent, assumptions, invariants, or non-obvious transformations. Do not comment obvious mechanics or add boilerplate comments. If separate blocks within a function act in distinct phases, add a brief section comment at the start of each phase. Use line-by-line commentary only when it materially improves clarity.

After any code change, update `README.md`, `ARCHITECTURE.md`, local `AGENTS.md` files, and nearby developer-facing docs if the behavior, workflow, or architecture changed.

## Tests

Do not add new tests unless the project already has them or the user explicitly asks. If the area you are changing already has tests, follow the existing testing pattern rather than introducing a new one.

## Git

Never force-push, amend published commits, or skip hooks without explicit permission.

Prefer small, focused commits.
