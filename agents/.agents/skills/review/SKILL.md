---
name: review
description: Maintainer-style code review of uncommitted changes, a commit, a branch, a PR, or a whole codebase. Reports only defects with a concrete failure scenario, scales the number of reviewers to the size of the change, and verifies findings before reporting them. Use when the user says "review this", "review the PR", "review this branch", "review the diff", or wants a repo audit.
allowed-tools: Agent Read Grep Glob Bash
---

# Review

Review as the maintainer of the codebase, not as the author of the change: judge whether this is the right change for this repository, not only whether it is coherent on its own. The review is read-only; report findings, and fix them only when the user asks.

## What counts as a finding

Report a problem only when all of these hold:

- The change introduces it, newly exposes it, or fails a stated requirement of the requested change (e.g. the task names two input forms and the fix covers one). Unrelated pre-existing problems are out of scope.
- You can write a concrete failure scenario: `input or state -> code path -> wrong result`, naming the actual functions and lines. A candidate you can't write this way is not a finding.
- It is one specific, actionable problem, not a general concern about the codebase.
- It isn't flagged only because the behavior changed: an intentional change is fine unless it breaks a requirement or a contract that other code depends on.
- The author would fix it if they knew, and the fix doesn't demand more rigor than the rest of the codebase has.

The scenario form covers more than runtime bugs:

- Docs and comments: see "Docs" below.
- Maintainability and system fit: name a maintenance cost the change creates today, or a documented extension contract it breaks; an imagined future editing mistake is not enough.
- Repo rules: a change that breaks a rule in `AGENTS.md`, `CLAUDE.md`, or another project instruction file is a finding without a scenario; cite the rule's file and line instead.

Don't report style a formatter or linter enforces, nitpicks a senior maintainer wouldn't raise, speculation that something "may affect" other code without naming that code, or performance problems unless the user asked or you can show the scenario for a severe regression.

Prefer no finding over a weak one; "No findings." is a complete result. After the first finding, keep going until the whole change is checked.

## Checks before any conclusion

Run these on every changed code path; they catch what reading the diff alone misses:

1. Function resolution: for each call the change adds or relies on, confirm which definition actually runs - local, module, import, builtin, or override. Name shadowing and wrong overloads hide here.
2. Sufficiency: does the change fix the root cause, or only the symptom the author saw?
3. Regression paths: for each changed behavior, trace at least one caller outside the diff that depends on it and confirm it still works.

Apply the checks that fit the changed behavior. Config and dependency changes need their consumers checked; purely editorial changes (docs wording, formatting) and bugs obvious within one function need no tracing.

## Docs

Docs are part of the change, held to the same bar as code: accurate, up to date, covering what a reader needs to use and change the code, and short - a short doc that covers everything beats a long reference. Search the docs, comments, docstrings, and help text for every name, flag, and behavior the change touches, and report:

- Stale or wrong: a doc the change contradicts. Scenario: "a reader follows `README.md:40`, passes `--foo`, and gets an unknown-flag error".
- Missing: the change adds or alters behavior, an interface, or a workflow that no doc covers, or that lacks docs the project's instruction files ask for. Scenario: a reader can't use or change the code correctly without reading the implementation.
- Bloated: docs the change adds or grows that restate the code, list detail a reader gets faster from the code, or repeat another doc. Name the cut.

## Target

- Uncommitted changes: `git diff HEAD`, plus untracked files.
- A commit: `git show <sha>`.
- A branch: `git diff <base>...<branch>` - three dots diff against the merge base, so only committed work that would merge gets reviewed; leave uncommitted changes out unless asked. Use the base's upstream when it is ahead of the local base branch.
- A PR: `gh pr diff <n>`, with `gh pr view <n>` for the stated intent.
- Unclear: ask.

Read the project's instruction files that apply to the changed files, and the commit or PR description for intent.

## Scale reviewers to the change

Size exactly what you are reviewing: `--stat` with the same range as the review diff, plus untracked files for uncommitted changes. Reviewer briefs use that same range.

- Small (under ~50 lines, 1-2 files): review it yourself, without sub-agents, including system fit - whether the change uses the right seam, layer, and existing repo pattern.
- Medium (~50-200 lines, or 3-5 files): one reviewer sub-agent takes the whole diff while you check system fit - whether the change uses the right seam, layer, and existing repo pattern.
- Large (over ~200 lines, or more than 5 files): split the diff by area (a module or a group of related files) and give each area its own reviewer, plus one system-fit reviewer that reads across areas. Split by area, not by kind of problem; each reviewer applies every rule here to its slice.

A reviewer brief contains the diff range and its area, the stated intent, the instruction files to read, the "What counts as a finding", "Checks before any conclusion", and "Docs" sections verbatim, and the output format below. It also says the review is read-only, and that the assigned area limits which findings the reviewer reports, not which code it may read. Never require findings in particular categories; every finding meets the same bar.

## Verify before reporting

Every candidate finding gets a separate verification pass against the cited code and the stated requirements:

- Small changes: re-check each finding yourself by re-reading the cited code path.
- Medium changes: cross-check the reviewer's findings yourself, and have the reviewer check yours.
- Large changes: give each P0-P2 finding to a fresh sub-agent whose job is to break the scenario using the code; check P3 findings yourself.

Report only findings the verification supports. A question that verification couldn't settle goes under residual risks, not under findings. Merge findings that share a location and a fix.

## Whole-codebase review

There is no change, so the "introduced by the change" rule falls away; every other rule stays. Pick representative hotspots - high churn in `git log --name-only`, core modules, untested code - rather than skimming every file, and split them across reviewers by area as in a large review. Report a recurring problem once, listing every location.

## Output

Findings first, most severe first:

```text
[P1] Imperative title - path/to/file.py:42
One paragraph: the failure scenario, and the inputs or conditions it depends on.
```

- P0: breaks release or core usage for everyone, with no special inputs.
- P1: should be fixed before merge.
- P2: a real defect to fix soon.
- P3: low impact, still worth fixing.

Cite locations in the file-reference format your instructions ask for, with short line ranges. For a change, keep citations inside the diff where possible and end with one line saying whether any confirmed finding blocks the change. For a whole-codebase review, end with what the review covered. Then list residual risks: test gaps on changed behavior, unsettled questions, and areas left unreviewed.
