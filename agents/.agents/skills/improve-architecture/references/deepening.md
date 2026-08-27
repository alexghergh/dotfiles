# Deepening — dependencies and testing strategy

How to deepen a cluster of shallow modules safely, given its dependencies. Assumes the vocabulary in [SKILL.md](../SKILL.md) — **module**, **interface**, **seam**, **adapter**.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem, testcontainers, an embedded Redis). Deepenable if the stand-in exists. The deepened module is tested with the stand-in running in the test suite. The seam is internal; no port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a **port** (interface) at the seam. The deep module owns the logic; the transport is injected as an **adapter**. Tests use an in-memory adapter. Production uses an HTTP/gRPC/queue adapter.

Recommendation shape: *"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. True external (Mock)

Third-party services you don't control (Stripe, Twilio, LLMs). The deepened module takes the external dependency as an injected port; tests provide a mock adapter.

## Seam discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a port unless at least two adapters are justified (typically production + test). A single-adapter seam is just indirection — cost without leverage.
- **Internal seams vs external seams.** A deep module can have internal seams (private to its implementation, used by its own tests) as well as the external seam at its interface. Don't expose internal seams through the interface just because tests use them.
- **The interface is the test surface.** If you find yourself wanting to test *past* the interface (call an internal function directly, poke at private state), the module is probably the wrong shape — either its interface is too narrow, or its implementation is too broad.

## Testing strategy: replace, don't layer

- Old unit tests on shallow modules become waste once tests at the deepened module's interface exist — delete them, don't stack the new tests on top.
- Write new tests at the deepened module's interface. The interface is the test surface.
- Tests assert on observable outcomes through the interface, not internal state.
- Tests should survive internal refactors — they describe behavior, not implementation. If a test has to change when the implementation changes without changing the behavior, it's testing past the interface.

## Deepening for testability — anti-patterns

- **Extracting a pure function "for testability" and testing it in isolation.** If the bug hides in how the pure function is called, the test doesn't catch it. Prefer to deepen the caller so the whole path is one testable module.
- **Adding a mock at every seam.** Mocks are for true-external dependencies. In-process and local-substitutable dependencies do not need mocks — use the real thing (or the stand-in) in the test.
- **Wrapping every external call in a port for one adapter.** Speculative generality (see review skill's Fowler baseline). Wait for the second adapter to appear; then introduce the port.
