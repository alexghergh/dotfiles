# Architecture

Evaluate separation of concerns, dependency direction, and extensibility.

## What to look for

- Clear module separation (e.g., core logic, I/O, configuration, CLI entry points)
- Dependencies point inward (core modules do not import from CLI or I/O layers)
- Proper package/dependency management (requirements.txt, pyproject.toml, Cargo.toml, go.mod — pinned versions, no unused deps)
- Separation of utilities/helpers from application logic
- Configuration separated from code (loaded at startup, injected or passed explicitly)
- New features can be added without modifying core abstractions
- No hidden global mutable state that complicates reasoning or testing
- Appropriate use of patterns for the language (traits in Rust, interfaces in Go, protocols in Python — not forced, not missing where needed)

## Examples

Good (4-5):
- Core logic is a library with no knowledge of how it's invoked (CLI, HTTP, tests all use the same API)
- Adding a new output format requires implementing one interface/trait, no changes to existing code
- Dependencies pinned in a lock file; no unused packages in the manifest
- Utility functions live in a dedicated module, not scattered across scripts
- Configuration loaded once at startup and threaded through as a struct/dict

Bad (1-2):
- A single script mixes argument parsing, business logic, file I/O, and output formatting
- Adding a simple feature requires modifying abstract base classes or core traits
- Global mutable state shared across modules without clear ownership
- No dependency manifest; imports resolved implicitly or vendored ad-hoc
- Utils duplicated across multiple scripts instead of shared from one module

## Grading

- **5**: Clean architecture; easy to extend, test, and reason about
- **4**: Mostly well-structured; minor layering violations
- **3**: Architecture works but has areas that resist change
- **2**: Significant architectural issues that make the system fragile
- **1**: No discernible architecture; everything depends on everything
