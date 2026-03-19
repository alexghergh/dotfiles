# Security

Evaluate code for security vulnerabilities and defensive practices.

## What to look for

- Input validation and sanitization at system boundaries
- Authentication and authorization checks
- Secrets and credentials handling (no hardcoded secrets, proper env usage)
- Injection vectors: SQL injection, command injection, path traversal, format string attacks
- Unsafe deserialization of untrusted data (pickle, yaml.load, serde from untrusted sources)
- Memory safety issues: buffer overflows, use-after-free, unchecked pointer dereference
- Race conditions and TOCTOU vulnerabilities in concurrent code
- Subprocess and shell invocation with unsanitized arguments
- Error messages that leak internal details or stack traces
- Proper use of cryptographic primitives (no deprecated algorithms, no custom crypto)
- File permission handling and temporary file creation
- Dependency vulnerabilities (known CVEs in imports)

## Examples

Good (4-5):
- User input validated at the boundary before reaching business logic
- Secrets loaded from environment variables or a vault, never in source
- Parameterized queries used consistently
- Subprocess calls use argument lists, never shell=True with interpolated strings
- Temporary files created with restricted permissions via proper stdlib APIs
- Concurrent access to shared state protected by locks or channels

Bad (1-2):
- String concatenation or f-string formatting for SQL queries with user input
- API key hardcoded in source file
- `os.system()` or `subprocess.run(shell=True)` with user-controlled arguments
- `pickle.loads()` / `yaml.load()` on untrusted input without safe loader
- File path accepted from user without canonicalization or chroot
- Cryptographic operations using MD5 or SHA1 for security purposes
- Race condition between checking a file and using it

## Grading

- **5**: No vulnerabilities found; security-sensitive code uses defense-in-depth
- **4**: No real vulnerabilities; minor hardening opportunities
- **3**: Low-severity issues present (e.g., missing input length limits)
- **2**: Medium-severity vulnerabilities (e.g., potential injection vectors)
- **1**: Critical vulnerability found (e.g., hardcoded secrets, command injection)
