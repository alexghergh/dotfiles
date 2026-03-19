# Documentation

Evaluate the quality and completeness of documentation and comments.

## What to look for

- Function and module docstrings for public interfaces
- Inline comments that make functions scannable: reading only the comments should make the function's logic clear without reading the code itself
- One-line comments that summarize what a code block does (e.g., "check whether the connection is active") when that is faster to grasp than reading the next 5-7 lines
- Multi-line in-depth comments for non-obvious or non-trivial algorithms, invariants, and business logic — these are a must, not optional
- Comments that explain intent, assumptions, and non-obvious decisions
- Accurate README and ARCHITECTURE docs that match the code
- No stale comments that contradict the implementation

## Examples

Good (4-5):
- A function's inline comments alone tell you what it does, step by step, without needing to parse the code
- Non-obvious algorithm has a multi-line comment explaining the approach, invariants, and edge cases
- One-line comment like "// retry with exponential backoff" before a loop, instead of forcing the reader to infer it from the code
- Public API functions document parameters, return values, and side effects
- README accurately describes setup, usage, and architecture

Bad (1-2):
- Complex business logic or non-trivial algorithm with zero comments
- A comment on every single line, polluting readability (e.g., `x = x + 1  // increment x`)
- Comments that describe obvious mechanics instead of intent
- README describes a feature that was removed two versions ago
- Stale comments that contradict what the code actually does

## Grading

- **5**: Documentation is accurate, concise, and helps new developers; inline comments make functions scannable; non-trivial code is thoroughly explained
- **4**: Well-documented; minor gaps in non-critical areas
- **3**: Key areas lack documentation or have stale comments; non-trivial logic is under-explained
- **2**: Documentation is sparse or misleading in important areas; functions require full code reading to understand
- **1**: No meaningful documentation; comments are absent or wrong
