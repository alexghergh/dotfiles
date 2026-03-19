---
name: review-worktrees
description: Comparative review across multiple git worktrees, grading each worktree per dimension and picking a winner.
---

# Comparative Worktree Review

Compare competing implementations across multiple git worktrees. Spawn one sub-agent per quality dimension; each sub-agent evaluates ALL worktrees for its dimension and compares them.

## Workflow

1. Run `git worktree list` to discover worktrees. Identify the main worktree (base) and feature worktrees (targets).
2. Assign stable labels such as `A`, `B`, `C` to the candidate worktrees in a fixed order. Show the mapping once near the top of the output and use those labels consistently afterward.
3. For each dimension file in `references/`, spawn a sub-agent:
   - The sub-agent reads its dimension file for criteria and rubric.
   - The sub-agent reviews every candidate worktree's diff against the base.
   - The sub-agent grades each labeled worktree (1-5) with evidence.
   - The sub-agent notes only differences that are genuinely useful for choosing a winner or improving one later. Prefer concise relative comparisons such as `A is better than B because ...` when they help the user decide. Do not force commentary if the grades and evidence already tell the story.
4. Collect all sub-agent results.
5. Produce a per-dimension comparison in list form, using the stable labels.
6. Pick a winner using both the dimension scores and the concrete findings. Do not choose by average score alone when one worktree has a blocking issue, obvious regression, or materially weaker mergeability.
7. Extract actionable findings from the non-winning worktrees that should be applied to the winner. Only carry over changes that fit the winner's current structure and do not reintroduce the losers' weaknesses.
8. Convert the best compatible improvements from the non-winning worktrees into a copy-pastable prompt addressed to the winning worktree.

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

### Worktree Map

- `base` — base worktree or branch used for comparison
- `A` — first candidate worktree
- `B` — second candidate worktree
- `C` — third candidate worktree

### Per-Dimension Comparison (from each sub-agent)

```text
maintainability:
A, grade: 4
B, grade: 3

- best: A
- A is better than B because parsing and validation stay separated instead of leaking into CLI code
- adopt into A: B has a small helper extraction in `src/foo.py` worth porting
```

If the grades already make the result obvious, omit the extra bullets. Do not force `pro:` / `con:` lines or pairwise comparisons just to fill space.

### Aggregated Summary (from root agent)

```text
overall:
A, overall: 4.1
B, overall: 3.6

- winner candidate: A
- A is the safer choice because it has no blocking regressions
```

Keep this section concise. Only add short notes that help justify the final decision.

### Final Recommendation

- `winner`: which worktree to use and why
- `why others lost`: blocking issues, regressions, or important trade-offs that kept them from winning
- `adopt from others`: specific improvements from non-winning worktrees to apply to the winner, with file references and a short note on why each change is compatible with the winner
- `prompt for winner`: a copy-pastable user message addressed to the winning worktree. Write it as a fenced `text` block in imperative user voice, for example "consider improving your implementation by ...". Keep it concrete, grounded in the reviewed code, and focused only on changes that should strengthen the winner without importing the losers' regressions. If there are no compatible improvements worth porting, say so explicitly instead of forcing a prompt.
- `remaining issues`: actionable findings that exist in all worktrees or still exist in the winner

## Grading Scale

- **5** — Exemplary: exceeds expectations, no issues found
- **4** — Good: minor suggestions only, no real concerns
- **3** — Acceptable: some issues worth addressing before merge
- **2** — Needs work: significant issues that should be fixed
- **1** — Critical: blocking issues, do not merge
