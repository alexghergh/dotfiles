# Correctness

Evaluate whether the code actually does the right thing.

## What to look for

- behavior that does not match the apparent intent of the change
- regressions in existing flows or edge cases
- wrong assumptions about data shape, control flow, ordering, or state
- missing validation or boundary handling that causes incorrect behavior
- partial fixes that patch a symptom without fixing the underlying bug
- error handling paths that silently hide failures or leave bad state behind
- obvious security-sensitive correctness mistakes when they affect behavior or safety

## Reviewer stance

- prioritize concrete bugs over style concerns
- stay grounded in the actual code paths involved
- if the review target is a change, ask whether the change solves the real problem
- if the review target is a whole codebase, focus on representative correctness risks and recurring failure patterns

## Examples

Good:
- a bug fix handles the real source of invalid state instead of only suppressing the visible error
- a new feature updates the full flow that consumes the new data, not just the first write site
- boundary validation rejects invalid input before state changes happen

Bad:
- the patch fixes the happy path but leaves adjacent call sites with the old broken behavior
- a feature writes data in one layer but never updates the reader or downstream consumer
- the code catches an error and continues as if the action succeeded

## Grading

- **5**: the reviewed code appears behaviorally correct with no meaningful regressions found
- **4**: no real bugs found; only minor edge questions or low-risk follow-ups
- **3**: some issues should be fixed before trusting the code fully
- **2**: significant bugs, regressions, or wrong assumptions are present
- **1**: blocking correctness failure; do not merge as written
