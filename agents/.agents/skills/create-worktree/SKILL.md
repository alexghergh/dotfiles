---
name: create-worktree
description: Create a git worktree for parallel development on a new branch.
---

# Create Worktree

Create a git worktree to work on a separate branch in parallel without switching the current checkout. Present the user with the git worktree command before running and ask for confirmation. Upon completion of changes, prompt the user on whether to remove the worktree. Do not automatically do that.

## Note on uncommitted changes

`git worktree add` does not require a clean working tree. The current checkout keeps its uncommitted changes and the new worktree starts clean. Proceed without blocking. If you notice uncommitted changes that look relevant to the new branch, mention them in passing and ask, but do not force a stash/commit step by default.

## Usage

```bash
git worktree add <path> -b <new-branch> [<start-point>]
```

- `<path>`: directory for the new worktree (e.g., `../project-feature-name`)
- `-b <new-branch>`: create and check out a new branch
- `<start-point>`: base commit or branch (defaults to HEAD)

## Example

```bash
git worktree add ../myproject-fix-auth -b fix/auth-token-refresh origin/main
```

This creates a worktree at `../myproject-fix-auth` on a new branch `fix/auth-token-refresh` based on `origin/main`.

## Cleanup

```bash
git worktree remove <path>
```

## Reference

https://git-scm.com/docs/git-worktree
