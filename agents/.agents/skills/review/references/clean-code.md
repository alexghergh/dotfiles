# Clean Code

Evaluate naming, formatting, DRY adherence, and single responsibility.

## What to look for

- descriptive, consistent naming for variables, functions, types
- consistent formatting and code style
- DRY: no duplicated logic across functions or modules
- single responsibility: each function/class does one thing
- dead code removal (unused functions, commented-out blocks, stale imports)
- appropriate function length (not doing too many things)

## Reviewer stance

- prioritize correctness and maintainability over perfect style consistency
- avoid abstracting just to satisfy a template; extract only when reuse or risk reduction is clear
- call out naming, duplication, and dead code issues only when they materially affect understanding or change safety
- prefer feedback that helps the next maintainer quickly infer intent

## Examples

Good:
- variable names clearly convey purpose and scope
- helper function extracted when the same logic appeared in two places
- each function fits on one screen and has a clear purpose
- no commented-out code or unused imports left behind

Bad:
- single-letter variable names outside tight loop counters
- same 15-line block copy-pasted in three places
- function named `processData` that validates, transforms, saves, and emails
- commented-out code blocks left "just in case"

## Grading

- **5**: Clean, readable, well-named; no dead code or duplication
- **4**: Mostly clean; minor naming or style inconsistencies
- **3**: Some duplication or unclear naming that slows comprehension
- **2**: Significant style violations, duplicated logic, or unclear names
- **1**: Inconsistent, messy code with rampant duplication
