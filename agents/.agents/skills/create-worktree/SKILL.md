---
name: create-worktree
description: Create a git worktree for parallel development on a new branch.
---

# Create Worktree

Create a git worktree to work on a separate branch in parallel without switching the current checkout.

## Prerequisites

Check for uncommitted changes before creating a worktree:

```bash
git status --porcelain
```

If there are uncommitted changes, do not proceed. Ask the user to choose what to do. Offer to either stash the changes or commit the changes.

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
