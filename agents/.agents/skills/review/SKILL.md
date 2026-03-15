---
name: review
description: Structured code review using parallel sub-agents that evaluate code across independent quality dimensions.
---

# Structured Code Review

Perform a structured review by evaluating code against independent quality dimensions. Spawn one sub-agent per dimension for parallel evaluation.

## Workflow

1. Identify the code to review (diff, file set, or worktree).
2. For each dimension file in `dimensions/`, spawn a sub-agent:
   - The sub-agent reads its dimension file for criteria and rubric.
   - The sub-agent evaluates the code against that single dimension.
   - The sub-agent returns a grade (1-5) with evidence.
3. Collect all sub-agent results.
4. Produce a summary table with all dimension grades.
5. Compute an overall average (rounded to one decimal).
6. List the top findings ordered by severity.

## Dimensions

Each file in `dimensions/` defines one review axis: what to look for, examples of good and bad code, and a grading rubric from 1 (critical issues) to 5 (exemplary).

Available dimensions:
- `security.md` — vulnerabilities, input validation, secrets handling
- `maintainability.md` — readability, modularity, coupling
- `performance.md` — algorithmic efficiency, resource usage, scaling
- `documentation.md` — comments, docstrings, README accuracy
- `clean-code.md` — naming, formatting, DRY, single responsibility
- `architecture.md` — separation of concerns, dependency direction, extensibility

## Output Format

| Dimension       | Grade | Key Finding                    |
|-----------------|-------|--------------------------------|
| Security        | 4     | Input validation present, ...  |
| Maintainability | 3     | High coupling between X and Y  |
| ...             | ...   | ...                            |
| **Overall**     | **3.5** |                              |

After the table, list actionable findings ordered by severity.

## Grading Scale

- **5** — Exemplary: exceeds expectations, no issues found
- **4** — Good: minor suggestions only, no real concerns
- **3** — Acceptable: some issues worth addressing before merge
- **2** — Needs work: significant issues that should be fixed
- **1** — Critical: blocking issues, do not merge
