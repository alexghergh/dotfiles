# Performance

Use this reference only when the user explicitly asks for performance review, or when another pass has already uncovered an obviously severe performance regression.

## What to look for

- algorithmic complexity that is clearly mismatched to expected scale
- repeated expensive work or unnecessary I/O in hot paths
- unbounded memory growth, unnecessary copies, or large retained objects
- query or fetch patterns that obviously multiply work
- blocking operations, lock contention, or resource handling problems in performance-sensitive paths
- opportunities to reuse existing repo patterns for efficient behavior

## Reviewer stance

- performance is secondary to correctness and system fit unless the regression is severe
- do not ask for speculative micro-optimizations
- tie findings to expected usage, hot paths, or concrete scale risks
- prefer explaining why the current shape is costly over suggesting generic optimizations

## Examples

Good:
- the review points out an obvious N+1 query on a path that already processes collections
- the code streams data where the old implementation buffered the full dataset
- a hot-path operation reuses an existing cache or batching layer already present in the repo

Bad:
- the review suggests generic caching without identifying a real repeated cost
- the review asks for optimization work before correctness or mergeability is settled
- the review flags tiny constant-factor issues in cold code paths

## Grading

- **5**: no meaningful performance concerns found for the requested review scope
- **4**: generally sound with only minor optimization opportunities
- **3**: some issues may matter under realistic usage
- **2**: clear performance problems should be addressed
- **1**: severe performance regression or scalability failure
