# Clean Code

Evaluate naming, formatting, DRY adherence, and single responsibility.

## What to look for

- Descriptive, consistent naming for variables, functions, types
- Consistent formatting and code style
- DRY: no duplicated logic across functions or modules
- Single responsibility: each function/class does one thing
- Dead code removal (unused functions, commented-out blocks, stale imports)
- Appropriate function length (not doing too many things)

## Examples

Good (4-5):
- Variable names clearly convey purpose and scope
- Helper function extracted when the same logic appeared in two places
- Each function fits on one screen and has a clear purpose
- No commented-out code or unused imports left behind

Bad (1-2):
- Single-letter variable names outside tight loop counters
- Same 15-line block copy-pasted in three places
- Function named `processData` that validates, transforms, saves, and emails
- Commented-out code blocks left "just in case"

## Grading

- **5**: Clean, readable, well-named; no dead code or duplication
- **4**: Mostly clean; minor naming or style inconsistencies
- **3**: Some duplication or unclear naming that slows comprehension
- **2**: Significant style violations, duplicated logic, or unclear names
- **1**: Inconsistent, messy code with rampant duplication
