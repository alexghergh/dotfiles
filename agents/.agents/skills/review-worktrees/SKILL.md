---
name: review-worktrees
description: Compare multiple git worktrees from a maintainer perspective using paired first-pass reviewers, fresh deeper passes, and priority-based winner selection.
---

# Comparative Worktree Review

Compare competing implementations as the maintainer of the codebase, not as the author of any candidate.
Do not choose a winner by average score.
Pick the safest, most apt implementation for this repository.

## Workflow

1. Run `git worktree list` to discover worktrees. Identify the base worktree and the candidate worktrees.
2. Assign stable labels such as `A`, `B`, `C` to the candidates in a fixed order. Show the mapping once near the top of the output and use those labels consistently afterward.
3. Spawn two first-pass sub-agents in parallel:
   - `precision reviewer`
     - inspect each candidate's diff against the base
     - surface concrete correctness bugs, regressions, stale or missing docs or comments, direct test gaps, and obvious integration mistakes
     - stay close to the changed code and produce a quick triage view of each candidate
   - `explorer reviewer`
     - inspect surrounding modules, extension points, similar implementations elsewhere in the repo, and local architecture docs when present
     - judge which candidates fit the repo best and whether any are solving the problem at the wrong seam or layer
     - review from a third-person maintainer perspective
4. Collect both first-pass summaries and produce a quick overview.
5. If the first pass already surfaces clear blockers or a clear winner, surface that promptly instead of spending time on unnecessary deeper review.
6. If deeper review is warranted, spawn fresh focused sub-agents. Do not continue with the original sub-agents.
7. Choose deeper reviewers based on the open questions from the first pass. Common follow-up reviewers:
   - `correctness reviewer`
   - `tests reviewer`
   - `documentation reviewer`
   - `system-fit reviewer`
   - `repo-consistency reviewer`
8. Do not run a dedicated performance review unless the user explicitly asks for one.
9. If an obvious catastrophic performance regression appears during another pass, report it as a finding, but do not branch into a full performance comparison unless requested.

## Decision Priorities

Use these priorities in order when choosing a winner:

1. correctness, regressions, and security-sensitive mistakes
2. system fit, mergeability, and consistency with repo patterns
3. tests, documentation, and comments for non-obvious logic
4. performance, only when explicitly requested

Use the following severity examples to keep labels consistent:
- high: guaranteed merge blockers, user-visible breakage, or immediate correctness/security regressions
- medium: likely regressions or integration risks that are fixable but should be addressed before merge
- low: localized maintainability, consistency, or clarity issues that improve quality but do not block merge

Use this grading convention internally when judging review quality from sub-agents, but don't expose this to the user:
- **5**: no meaningful regressions found and the change is behaviorally sound for the stated scope
- **4**: mostly good; only minor edge follow-ups or low-risk concerns
- **3**: important issues remain and the change should be improved before full trust
- **2**: significant regressions or high-risk problems are likely
- **1**: blocking issue; do not merge as written

Reject or demote candidates with higher-priority failures even if they look cleaner or faster elsewhere.

## References

Use the reference files selectively. Not every comparison needs every reference.

- [correctness.md](references/correctness.md) — bugs, regressions, wrong assumptions, broken behavior
- [architecture.md](references/architecture.md) — system fit, layering, extension points, repo patterns
- [tests.md](references/tests.md) — coverage of changed behavior, test quality, avoiding test theater
- [documentation.md](references/documentation.md) — stale or missing docs, misleading comments, public interface docs
- [security.md](references/security.md) — vulnerabilities, boundary validation, secrets handling
- [maintainability.md](references/maintainability.md) — changeability, coupling, structural friction
- [clean-code.md](references/clean-code.md) — naming, duplication, dead code, local readability
- [performance.md](references/performance.md) — opt-in performance review only

## Output Format

Prefer list output over tables. The result should be easy to scan in a terminal.

### Worktree Map

- `base` — base worktree or branch used for comparison
- `A` — first candidate worktree
- `B` — second candidate worktree
- `C` — third candidate worktree

### Quick Overview

Start with the two first-pass summaries:

```text
quick overview:
- precision reviewer: one or two concrete candidate issues or "no immediate blockers found"
- explorer reviewer: one or two system-fit comparisons or "no broader fit issues found"
```

### Findings

Report findings in this order:

```text
blocking issues:
1. high — `A` — `path/to/file.py:42` — concrete bug, regression, or wrong integration point

merge-readiness issues:
1. medium — `B` — `path/to/file.py:87` — missing or misleading tests, docs, comments, or maintainability issue that should be fixed

consistency and architecture concerns:
1. medium — `C` — `path/to/file.py:12` — inconsistent repo pattern or wrong layer for the behavior

performance:
- not reviewed
```

### Final Recommendation

- `winner`: the worktree to use and why
- `why others lost`: the highest-priority reasons they should not win
- `adopt from others`: only compatible improvements that strengthen the winner without importing higher-priority weaknesses
- `prompt for winner`: a copy-pastable user message addressed to the winner with only those compatible improvements
- `remaining issues`: findings that still exist in the winner or across all candidates

If performance was requested, then append the list with the actual findings.

## Review Limits

If the candidate set is large, keep the first pass broad and use deeper reviewers only where the first pass identified real uncertainty.
Do not spend time on low-priority polish when higher-priority winner-selection issues are still unresolved.
