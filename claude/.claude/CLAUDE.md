@~/.agents/AGENTS.md

## Command discipline: prefer prompt-free forms

Never run a command that triggers a user approval prompt when a prompt-free form
covers the need. The allow list below is live-tested and up-to-date. Treat it as
closed-world: a command absent from it is assumed to prompt until live-tested;
reach for the dedicated tools (Read / Grep / Glob) or an on-list form instead of
inferring freeness from similar commands or from other standing rules.

- `git -C <path> ...` matches no allow pattern and always prompts; the plain cwd
  forms (`git status`, `git diff`, `git log`, `git show`, ...) run free. Never
  use `-C` - run git from the repo cwd.
- Chains and pipelines run without a prompt only when every subcommand is
  independently allowlisted or read-only (`git log --oneline && git branch -v`,
  `cat X | head -3`).
- Read-only shell (`ls`, `find`, `rg`, `cat`, `head`, `grep`, `echo`) runs free
  in the sandbox; the dedicated Read / Grep / Glob tools stay preferred, but a
  read-only shell fallback is not a prompt risk.
- `sed` / `awk` prompt as leading commands even with `--sandbox`; read file
  slices via Read (`offset` / `limit`) instead of `sed -n`. Do not rely on an
  allowlisted pipeline leader to make a later command prompt-free.
- `uv run [--no-sync] ruff / black / mypy / pytest` are allowlisted but fail
  inside the sandbox (uv cache lock on a read-only fs); running them costs one
  deliberate sandbox-disable ask per batch - accepted, not avoidable.
- The settings ask-list (state-modifying git, `rm`, `mv`, `npm`, `pip`) and
  deny-list (`git push`, `sudo`, ...) prompt or block by design; the standing
  rules already reserve those for the user.

Sub-agents follow the same command discipline. Foreground sub-agents pass
permission prompts through; background sub-agents auto-deny calls that would
prompt. Keep work that may require approval in the foreground, and do not end
the turn until every started sub-agent has finished.
