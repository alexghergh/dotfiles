---
name: improve-architecture
description: Scan a codebase for deepening opportunities - refactors that turn shallow modules into deep ones - present them as a visual HTML report, then walk through whichever the user picks with a grilling loop. Use when the user says "the codebase feels like a mudball", "let's clean this up", "audit the architecture", "improve architecture", or reports architectural friction (hard to test, hard to change, hard to navigate).
allowed-tools: Agent Skill Read Grep Glob Bash Write
---

# Improve Architecture

Surface architectural friction in a codebase and propose **deepening opportunities** - refactors that turn shallow modules into deep ones. The aims are testability, changeability, and AI-navigability.

Use the vocabulary in the [Codebase Design Vocabulary](#codebase-design-vocabulary) section exactly - don't drift into "component," "service," "API," or "boundary." Consistent language is what makes the suggestions comparable across candidates and reviews.

## Process

### 1. Explore

Use the Agent tool with `subagent_type=Explore` (or read the repo yourself if it's small) to walk the codebase looking for friction. Don't apply rigid heuristics - explore organically and note where you feel resistance:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** - the interface is nearly as complex as the implementation?
- Where have pure functions been extracted for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?
- Which files change together every time? (Recurring co-editing suggests they should be one module.)
- Where does the same concept have three different names?

Ground candidates in evidence, not resistance alone: pull co-change sets from `git log --name-only` (files that keep appearing in the same commits belong together), and mine past-session transcripts under `~/.claude/projects/` for friction the user already reported ("hard to test", "over-engineered", "can we trim this code down") - those complaints name the modules that hurt. Each candidate card cites its evidence (churn counts, complaint quotes, test-to-interface mismatches) so the recommendation badges are checkable rather than taste.

Apply the **deletion test** (see [Principles](#principles)) to anything you suspect is shallow. Only the "concentrates" signal - complexity reappearing across callers when the module is removed - is what you want; the "vanishes" signal means you keep hunting.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to `/tmp/claude/architecture-review-<timestamp>.html` so nothing lands in the repo (`%TEMP%` on Windows). Open it for the user - `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows - and print the absolute path.

The report uses **Tailwind via CDN** for layout and **Mermaid via CDN** for graph-shaped diagrams. Mix Mermaid with hand-crafted CSS/SVG for editorial visuals (mass diagrams, cross-sections). Use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences); use hand-built divs/SVG when you want something more expressive. Each candidate gets a **before/after visualization**. Be visual - the diagrams do the explaining.

See [references/html-report.md](references/html-report.md) for the full HTML scaffold, diagram patterns, and styling notes.

For each candidate, render a card with:

- **Title** - short, names the deepening ("Collapse the X pipeline", "Unify the Y adapters")
- **Recommendation strength** badge - `Strong` (emerald), `Worth exploring` (amber), `Speculative` (slate)
- **Files** - the files/modules involved, monospaced
- **Evidence** - what produced this candidate: churn counts, complaint quotes, test-to-interface mismatches
- **Problem** - one sentence, what hurts
- **Solution** - one sentence, what changes
- **Before / After diagram** - side by side, custom-drawn where possible
- **Wins** - bullets, <=6 words each ("Tests hit one interface", "Delete 4 shallow wrappers", "One place to fix bugs")

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, run a grilling session (invoke `grill-me`, or run the loop yourself if you're already in the flow) to walk the design tree with them:

- What constraints does the deepened module need to satisfy?
- What dependencies does it have, and which category (in-process / local-substitutable / remote-owned / true-external)? See [references/deepening.md](references/deepening.md).
- What sits behind the seam, and what stays outside?
- What tests survive the deepening? What tests get deleted?
- Where does the seam go? (Interface placement is its own design decision, separate from what the deepened module contains.)
- Is one adapter enough (hypothetical seam), or are there really two variants that justify a real seam?

Update the candidate's card in place - or produce a follow-up spec doc - as decisions crystallize.

End the loop by rendering the proposed interface - signatures, invariants, error modes, a before/after sketch - for the user to grade where it rings false, before any implementation begins.

## Codebase Design Vocabulary

Use these terms exactly. Don't substitute "component," "service," "API," or "boundary."

**Module** - anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice. *Avoid*: unit, component, service.

**Interface** - everything a caller must know to use the module correctly: the type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics. *Avoid*: API, signature (too narrow - they refer only to the type-level surface).

**Implementation** - what's inside a module, its body of code. Distinct from **adapter**: something can be a small adapter with a large implementation (a Postgres repo) or a large adapter with a small implementation (an in-memory fake).

**Depth** - leverage at the interface: the amount of behavior a caller (or test) can exercise per unit of interface they have to learn. A module is **deep** when a large amount of behavior sits behind a small interface, **shallow** when the interface is nearly as complex as the implementation.

**Seam** *(Michael Feathers)* - a place where you can alter behavior without editing in that place. The *location* at which a module's interface lives. Where to put the seam is its own design decision, distinct from what goes behind it. *Avoid*: boundary (overloaded with DDD's bounded context).

**Adapter** - a concrete thing that satisfies an interface at a seam. Describes *role* (what slot it fills), not substance (what's inside).

**Leverage** - what callers get from depth: more capability per unit of interface learned. One implementation pays back across N call sites and M tests.

**Locality** - what maintainers get from depth: change, bugs, knowledge, and verification concentrate in one place rather than spreading across callers. Fix once, fixed everywhere.

When designing an interface, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module can be internally composed of small, mockable, swappable parts - they just aren't part of the interface. A module can have **internal seams** (private to its implementation, used by its own tests) as well as the **external seam** at its interface.
- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. If you want to test *past* the interface, the module is probably the wrong shape.
- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a seam unless something actually varies across it.

## References

- [html-report.md](references/html-report.md) - HTML scaffold, diagram patterns, and styling for the report step
- [deepening.md](references/deepening.md) - how to deepen a cluster given its dependency categories (in-process, local-substitutable, remote-owned, true-external)
