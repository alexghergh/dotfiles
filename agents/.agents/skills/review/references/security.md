# Security

Evaluate code for security vulnerabilities and defensive practices.

## What to look for

- input validation and sanitization at system boundaries
- authentication and authorization checks
- secrets and credentials handling (no hardcoded secrets, proper env usage)
- injection vectors: SQL injection, command injection, path traversal, format string attacks
- unsafe deserialization of untrusted data (for example Python `pickle`, YAML loaders, Rust `serde`, etc. using language-appropriate safe APIs)
- memory safety issues (buffer overflows, use-after-free, unchecked pointer dereference) in unsafe code paths, FFI layers, or native extensions
- race conditions and TOCTOU vulnerabilities in concurrent code
- subprocess and shell invocation with unsanitized arguments
- error messages that leak internal details or stack traces
- proper use of cryptographic primitives (no deprecated algorithms, no custom crypto)
- file permission handling and temporary file creation
- dependency vulnerabilities (known CVEs in imports)

## Reviewer stance

- prioritize concrete vulnerabilities and realistic exploitability over theoretical or stylistic issues
- require boundary validation, safe parsing, and least-privilege defaults before praising behavior
- flag risky security assumptions even when they are “internal only” until evidence proves they’re isolated
- ask for verification of fixes where confidentiality, integrity, or authentication boundaries are implicated

## Examples

Good:
- user input validated at the boundary before reaching business logic
- secrets loaded from environment variables or a vault, never in source
- parameterized queries used consistently
- subprocess calls use argument lists, avoid shell-based string interpolation
- temporary files created with restricted permissions via proper stdlib APIs
- concurrent access to shared state protected by locks or channels

Bad:
- string concatenation or f-string formatting for SQL queries with user input
- API key hardcoded in source file
- shell string invocation with user-controlled arguments
- unsafe deserialization on untrusted input without safe decoding mode
- file path accepted from user without canonicalization or chroot
- cryptographic operations using MD5 or SHA1 for security purposes
- race condition between checking a file and using it

## Grading

- **5**: No vulnerabilities found; security-sensitive code uses defense-in-depth
- **4**: No real vulnerabilities; minor hardening opportunities
- **3**: Low-severity issues present (e.g., missing input length limits)
- **2**: Medium-severity vulnerabilities (e.g., potential injection vectors)
- **1**: Critical vulnerability found (e.g., hardcoded secrets, command injection)
