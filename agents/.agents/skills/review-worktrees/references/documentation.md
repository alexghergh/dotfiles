# Documentation

Evaluate whether documentation and comments still reflect each candidate.

## What to look for

- stale, missing, or misleading README, architecture notes, usage docs, or public interface docs
- comments that now contradict the implementation
- missing explanation for non-obvious logic, invariants, surprising decisions, or tricky data flow
- public interfaces whose arguments, return values, or side effects are no longer documented clearly
- docs that should have changed because behavior or workflow changed

## Review stance

- prioritize correctness over volume
- do not reward narration comments on straightforward code
- ask for comments when the code is easy to misunderstand, easy to misuse, or enforcing a non-obvious invariant
- compare candidates on whether their docs and comments will help the next maintainer

## Examples

Good:
- a behavior change updates the nearby README or developer doc that describes that flow
- a tricky invariant has a short comment explaining why the code is structured that way
- a public interface documents the side effect that callers need to know

Bad:
- docs still describe the previous behavior after the implementation changed
- a complex workaround or invariant is left unexplained
- review feedback rewards a candidate for extra comments that only restate obvious code

## Grading

- **5**: docs and comments are accurate, useful, and aligned with the implementation
- **4**: minor documentation gaps only
- **3**: important docs or comments are missing, stale, or under-explained
- **2**: documentation is misleading in areas that matter for maintenance or usage
- **1**: docs and comments are absent or wrong in ways that materially mislead readers
