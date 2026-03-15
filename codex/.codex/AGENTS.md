## Intent

Prefer the smallest correct change that fits the existing codebase.

Avoid over-engineering. Keep code DRY, but do not invent abstractions early. Reuse existing utility modules when they already fit the problem, and only extract helpers when the logic is clearly reusable across multiple code paths or meaningfully improves clarity.

## Workflow

Read before editing. Explore before planning. Plan before implementing.

Before making changes:
- read the relevant code paths first
- read the documentation relevant to the area you are changing, including `README.md`, `ARCHITECTURE.md`, and local `AGENTS.md` files when present
- ask questions for any non-obvious product or implementation choice until you are at least 95% confident the intended change matches the user's expectation

Before implementing, preview the intended approach briefly:
- say what you plan to change
- call out important trade-offs or risks
- recommend one path with reasoning instead of presenting a large menu of options

If the change would expand beyond the current scope, affect code paths outside the user's apparent target area, or require invasive refactors, ask for approval before proceeding. If you notice nearby issues worth fixing, flag them separately rather than bundling them in.

When uncertain, ask rather than guess.

## Code Style

Match the project's existing style, structure, and conventions.

Keep implementations simple and direct:
- avoid duplicate logic
- avoid defensive code for unrealistic failure modes just to appear safe
- do not introduce bugs, security issues, or unnecessary complexity

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
