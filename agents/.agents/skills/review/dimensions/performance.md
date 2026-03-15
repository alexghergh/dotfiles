# Performance

Evaluate algorithmic efficiency, resource usage, and scalability.

## What to look for

- Algorithmic complexity (unnecessary O(n²) or worse)
- Redundant computation or repeated I/O
- Memory allocation patterns (leaks, unnecessary copies, unbounded growth)
- Database query efficiency (N+1 queries, missing indexes, full table scans)
- Caching where appropriate
- Concurrency issues (blocking operations on hot paths, lock contention)
- Resource cleanup (open file handles, connections, goroutines, threads)

## Examples

Good (4-5):
- Batch database queries instead of per-item lookups
- Lazy evaluation for expensive computations that may not be needed
- Appropriate data structures for the access pattern
- Resources released via context managers, defer, or RAII

Bad (1-2):
- Nested loop over two large collections when a hash join would work
- Loading entire dataset into memory when streaming would suffice
- N+1 database queries in a loop
- File handles or connections opened but never closed on error paths

## Grading

- **5**: Efficient algorithms, no wasted resources, scales well
- **4**: Generally efficient; minor optimization opportunities
- **3**: Some inefficiencies that matter at moderate scale
- **2**: Significant performance issues likely under normal load
- **1**: Will not function acceptably at expected scale
