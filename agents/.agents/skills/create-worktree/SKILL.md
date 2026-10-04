---
name: create-worktree
description: Create a git worktree for parallel development on a new branch.
---

# Create Worktree

Create a git worktree to work on a separate branch in parallel without switching the current checkout. Put it in a sibling directory named after the project and the feature, e.g. `../myproject-fix-auth`.

Show the user the `git worktree add` command and ask for confirmation before running it. When the work is done, ask whether to remove the worktree; never remove it on your own.

Uncommitted changes in the current checkout don't block `git worktree add`. If some look relevant to the new branch, mention them and ask, but don't force a stash or commit.
