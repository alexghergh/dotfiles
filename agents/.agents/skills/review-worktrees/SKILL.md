---
name: review-worktrees
description: Comparative review across multiple git worktrees, grading each worktree per dimension and picking a winner.
---

# Comparative Worktree Review

Compare competing implementations across multiple git worktrees. Spawn one sub-agent per quality dimension; each sub-agent evaluates ALL worktrees for its dimension and compares them.

## Workflow

1. Run `git worktree list` to discover worktrees. Identify the main worktree (base) and feature worktrees (targets).
2. For each dimension file in `review/dimensions/`, spawn a sub-agent:
   - The sub-agent reads its dimension file for criteria and rubric.
   - The sub-agent reviews every feature worktree's diff against the base.
   - The sub-agent grades each worktree (1-5) with evidence.
   - The sub-agent compares the worktrees: strengths and weaknesses of each relative to the others.
3. Collect all sub-agent results.
4. Produce a per-worktree summary table with dimension grades.
5. Pick a winner based on overall scores.
6. Extract actionable findings from the non-winning worktrees that should be applied to the winner.

## Output Format

### Per-Dimension Comparison (from each sub-agent)

| Worktree       | Grade | Strengths              | Weaknesses             |
|----------------|-------|------------------------|------------------------|
| feature-a      | 4     | Clean validation logic | Missing edge case X    |
| feature-b      | 3     | Handles edge case X    | Duplicated logic in Y  |

### Aggregated Summary (from root agent)

| Dimension       | feature-a | feature-b | ... |
|-----------------|-----------|-----------|-----|
| Security        | 4         | 3         |     |
| Maintainability | 3         | 4         |     |
| ...             | ...       | ...       |     |
| **Overall**     | **3.5**   | **3.5**   |     |

### Final Recommendation

1. **Winner**: which worktree to use and why.
2. **Adopt from others**: specific improvements from non-winning worktrees to apply to the winner, with file references.
3. **Remaining issues**: actionable findings that exist in all worktrees.

## Grading Scale

Same as `review` skill:
- **5** — Exemplary  — **4** — Good  — **3** — Acceptable  — **2** — Needs work  — **1** — Critical
