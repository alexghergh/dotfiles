# Architecture

Evaluate whether each candidate fits the surrounding system.

## What to look for

- whether the behavior lives at the correct layer
- whether the code uses the repo's existing seams, abstractions, and extension points
- whether similar code elsewhere in the repo follows a different pattern that should be reused here
- whether the change solves the underlying problem instead of patching a local symptom
- whether responsibilities are split in a way that matches the rest of the codebase
- whether the implementation will be easy to merge, extend, and maintain within this repository
- whether repo-level docs, configuration shape, or dependency boundaries are now out of sync with the implementation

## Reviewer stance

- review from a third-person maintainer perspective
- do not defend a candidate because it is coherent in isolation
- ask whether it is the apt implementation for this repository
- compare candidates on system fit before discussing local polish

## Examples

Good:
- a candidate adds the behavior through the existing extension point instead of bypassing it in a local shortcut
- a fix is applied where the bad state originates, not at the final rendering layer
- code follows the same pattern that parallel features already use in the repo

Bad:
- a CLI, transport, or UI layer absorbs business logic that already has a better home elsewhere
- a candidate copies a nearby legacy pattern while the modern repo pattern lives in another module
- a local patch silences a symptom while the root contract mismatch remains in the system

## Grading

- **5**: the candidate fits the repo cleanly and uses the right seams and layers
- **4**: mostly good fit with only minor integration questions
- **3**: workable but there are notable fit or layering concerns
- **2**: significant system-fit problems make the candidate hard to merge safely
- **1**: the candidate is fundamentally implemented at the wrong seam or layer
