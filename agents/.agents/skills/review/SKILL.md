---
name: review
description: Maintainer-style code review for local changes, worktrees, or whole codebases using paired first-pass sub-agents and fresh deeper passes when needed.
---

# Maintainer Review

Review code as the maintainer of the codebase, not as the author of the implementation.
Do not defend a patch just because it is locally coherent.
Judge whether it is the apt change for this repository.

## Workflow

1. Identify the review target:
   - targeted change review for a diff, file set, branch, or worktree
   - whole-codebase review for repo-wide structure and implementation quality
2. Spawn two first-pass sub-agents in parallel and keep their responsibilities separate.

### Targeted change review

Spawn:
- `precision reviewer`
  - inspect the changed files, immediate callers or callees, nearby tests, and directly affected docs
  - surface concrete correctness bugs, regressions, stale or missing docs or comments, direct test gaps, and obvious integration mistakes
  - stay close to the target and optimize for immediate actionable findings
- `explorer reviewer`
  - inspect surrounding modules, extension points, similar implementations elsewhere in the repo, and local architecture docs when present
  - judge whether the change uses the right seam, layer, and repo pattern
  - review from a third-person maintainer perspective and look for system-fit problems that are easy to miss when staying near the diff

### Whole-codebase review

Spawn:
- `implementation reviewer`
  - inspect representative hotspots and concrete code paths for correctness risks, stale docs or comments, weak or misleading tests where tests already exist, and practical implementation issues
  - focus on low-level realities, not just structure
- `architecture reviewer`
  - inspect the repo at a high level for layering, seams, consistency, duplication, and documentation drift
  - focus on the forest, not individual trees

3. Collect both first-pass summaries and produce a quick overview.
4. If either first pass already surfaces clear blocking issues or enough actionable findings, surface them promptly instead of spending time on unnecessary deeper review.
5. If deeper review is warranted, spawn fresh focused sub-agents for the next passes. Do not continue with the original sub-agents; keep contexts narrow.
6. Choose deeper reviewers based on what the first pass uncovered. Common follow-up reviewers:
   - `correctness reviewer`
   - `tests reviewer`
   - `documentation reviewer`
   - `system-fit reviewer`
   - `repo-consistency reviewer`
7. Do not run a dedicated performance review unless the user explicitly asks for one.
8. If an obvious catastrophic performance regression appears during another pass, report it as a finding, but do not branch into a full performance review unless requested.

## Review Priorities

Apply these priorities in order.

1. correctness, regressions, security-sensitive mistakes, and whether the change solves the right problem
2. system fit, integration quality, and codebase consistency
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

Do not let lower-priority concerns drown out merge-blocking correctness or integration issues.

## References

Use the reference files selectively. Not every review needs every reference.

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

### Quick Overview

Start with the two first-pass summaries:

```text
quick overview:
- precision reviewer: one or two concrete issues or "no immediate blockers found"
- explorer reviewer: one or two system-fit issues or "no broader fit issues found"
```

For whole-codebase review, replace the reviewer labels with `architecture reviewer` and `implementation reviewer`.

### Findings

Report findings in this order:

```text
blocking issues:
1. high — `path/to/file.py:42` — concrete bug, regression, or wrong integration point

merge-readiness issues:
1. medium — `path/to/file.py:87` — missing or misleading tests, docs, comments, or maintainability issue that should be fixed

consistency and architecture concerns:
1. medium — `path/to/file.py:12` — inconsistent repo pattern or wrong layer for the behavior

performance:
- not reviewed
```

If performance was requested, then append the list with the actual findings.

If no findings are discovered, say so explicitly and then list residual risks or review limits.

## Review Limits

When the request is narrow, keep the review narrow unless the first-pass explorer finds a good reason to widen it.
When the request is broad, prefer representative hotspots and recurring patterns over shallow commentary on every file.
