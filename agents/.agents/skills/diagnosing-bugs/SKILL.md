---
name: diagnosing-bugs
description: Disciplined evidence-first workflow for diagnosing non-trivial bugs, flakes, hangs, and performance regressions. Use when the user asks to diagnose or debug a failure, or when a reported problem is intermittent, non-local, difficult to reproduce, or lacks an obvious cause. Use the triage fast path for localized failures with a clear signal. A diagnosis request does not authorize implementing a fix.
allowed-tools: Bash Read Edit Write Grep Glob
---

# Diagnosing Bugs

The method - triage, reproduce, hypothesize, probe - is assumed. This file holds only the policies and mechanics that do not happen by default.

## Policy

- A diagnosis request does not authorize a fix. Report the finding and stop; implement only when a fix is explicitly in scope.
- Ask before changing tracked files when the scope is diagnosis only, and before instrumenting a production or shared environment.

## Gates

- No root-cause claim from code reading or pattern matching alone. Confirmed means: the cause explains the exact symptom, a discriminating probe supports its prediction, and the strongest alternatives are weakened or ruled out. Anything less gets reported as a confidence level with the competing explanations and the next evidence needed - do not turn uncertainty into certainty by wording.
- No fix reported without re-running the original symptom signal. A red-capable signal reproduces the exact symptom before the fix and goes green after it; "should work now" is not a report.
- When no runnable loop exists (inaccessible environment, captured artifacts only): state what the artifact directly shows, derive falsifiable predictions per plausible cause, test them against the artifacts, and label conclusions confirmed, probable, or possible.

## Mechanics

- Tag temporary instrumentation with one hunt id and a probe suffix, e.g. `[DBG-a4f2:restore]`; cleanup is then one `rg 'DBG-a4f2'`. Remove it all before closing.
- Flakes: record the pre-fix reproduction rate and sample size before changing anything, then compare post-fix runs under the same conditions. One green run is not verification. Injected sleeps are probes, never fixes - they mask or move races.
- Performance: measure a baseline with variance and define the regression threshold before changing code; the signal is a measurement, not a boolean failure.
- Regression tests: mutation-check them - break the behavior, confirm the test goes red, restore, confirm green. Prefer a seam that exercises the real failure pattern; a test that cannot reproduce the causal chain gives false confidence.
- Bisection that changes repository state runs in a separate worktree.
- Before closing: re-run the original scenario (not only the reduced one), sweep the hunt id, remove throwaway harnesses, and restore any repository or environment state, including an active bisection.
