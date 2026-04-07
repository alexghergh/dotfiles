# Tests

Evaluate whether tests meaningfully support the reviewed code.

## What to look for

- whether the changed behavior is covered when the project already relies on tests in that area
- whether tests exercise the real path that changed instead of only nearby helpers
- whether added tests would catch the kind of bug or regression under review
- whether existing tests became stale or misleading after the change
- whether tests are missing in places where the repo clearly expects them
- whether the test shape fits the project's existing testing style and layer boundaries

## Reviewer stance

- do not ask for tests just to increase coverage numbers
- do not demand new tests in untested areas unless the change materially raises regression risk
- prefer a small number of behaviorally correct tests over broad shallow coverage
- call out weak assertions, wrong-layer tests, or tests that only restate implementation details

## Examples

Good:
- a regression fix includes a test that fails on the old behavior and passes on the new behavior
- the test exercises the public behavior that changed instead of only mocking internals
- a code path with existing tests extends those tests rather than inventing a new test pattern

Bad:
- tests only cover a helper while the actual bug lived in the integration path
- a new test asserts internal implementation details that can change without breaking behavior
- the review asks for many extra tests without showing what risk they would cover
- tests are added just to increase coverage, without meaningful targeted scope

## Grading

- **5**: tests are appropriately scoped, behaviorally meaningful, and aligned with the codebase
- **4**: good testing shape with only minor gaps
- **3**: useful coverage exists but notable gaps or weak assertions remain
- **2**: testing misses important changed behavior or uses the wrong layer
- **1**: tests are absent or misleading where they are clearly needed for safe change
