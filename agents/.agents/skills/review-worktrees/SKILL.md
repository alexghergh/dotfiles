---
name: review-worktrees
description: Compare competing implementations of the same task in several git worktrees and pick the one to keep, reviewing each candidate with the review skill's rules.
---

# Review Worktrees

Compare the candidates as the maintainer: pick the safest, most apt implementation for this repository, not the one with the fewest findings.

1. Run `git worktree list`, identify the base and the candidates, and label the candidates `A`, `B`, `C`, ... in a fixed order.
2. Review each candidate's diff against the base following the review skill (`../review/SKILL.md`): its finding rules, checks, reviewer scaling, and verification. Each candidate gets its own reviewer, and no brief mentions the other candidates. Establish whether each candidate includes uncommitted work, and give its reviewer the absolute worktree path, the resolved base, and the exact range to review; the reviewer reads supporting code from that worktree, not from yours.
3. Rank by the most severe problem first: correctness and regressions, then system fit and consistency with repo patterns, then tests and docs. A candidate with a confirmed P0 or P1 loses to one without, however clean it looks elsewhere.

Output:

- the worktree map: label, path, and branch
- findings per candidate, in the review skill's format
- the winner, and why each other candidate lost
- what to adopt from the others: only improvements that don't bring their problems along
- a copy-pastable message for the winner's session asking for those improvements and fixes for its remaining findings
