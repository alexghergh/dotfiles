---
name: review
description: Structured code review using parallel sub-agents that evaluate code across independent quality dimensions.
---

# Structured Code Review

Perform a structured review by evaluating code against independent quality dimensions. Spawn one sub-agent per dimension for parallel evaluation.

## Workflow

1. Identify the code to review (diff, file set, or worktree).
2. For each dimension file in `references/`, spawn a sub-agent:
   - The sub-agent reads its dimension file for criteria and rubric.
   - The sub-agent evaluates the code against that single dimension.
   - The sub-agent returns a grade (1-5) with evidence, concrete file references, and only actionable findings.
   - The sub-agent may include concise `pro:` and `con:` lines when they help explain the grade. Do not force both sides, and do not add filler praise or criticism just to balance the output.
3. Collect all sub-agent results.
4. Produce a grade summary in list form, not a table.
5. List the top findings ordered by severity. Prioritize bugs, regressions, documentation, coding style, problems, security issues.
6. If no findings are discovered, say so explicitly and call out any residual risks.

## Dimensions

Each file in `references/` defines one review axis: what to look for, examples of good and bad code, and a grading rubric from 1 (critical issues) to 5 (exemplary).

Available dimensions:
- [security.md](references/security.md) — vulnerabilities, input validation, secrets handling
- [maintainability.md](references/maintainability.md) — readability, modularity, coupling
- [performance.md](references/performance.md) — algorithmic efficiency, resource usage, scaling
- [documentation.md](references/documentation.md) — comments, docstrings, README accuracy
- [clean-code.md](references/clean-code.md) — naming, formatting, DRY, single responsibility
- [architecture.md](references/architecture.md) — separation of concerns, dependency direction, extensibility

## Output Format

Prefer list output over tables. The result should be easy to scan in a terminal.

### Grade Summary

```text
maintainability:
grade: 4
pro: parsing and validation are separated cleanly in `src/foo.py`
con: retry logic is duplicated in `src/bar.py` and `src/baz.py`

security:
grade: 5
```

Include `pro:` and `con:` only when they genuinely help explain the grade.

### Findings

1. high — `path/to/file.py:42` — description of the issue and why it matters
2. medium — `path/to/other_file.py:18` — description of the issue and why it matters

If there are no findings, state that clearly before listing residual risks.

## Grading Scale

- **5** — Exemplary: exceeds expectations, no issues found
- **4** — Good: minor suggestions only, no real concerns
- **3** — Acceptable: some issues worth addressing before merge
- **2** — Needs work: significant issues that should be fixed
- **1** — Critical: blocking issues, do not merge
