# HTML Report Format

The architectural review is rendered as a single self-contained HTML file in the OS temp directory, built the same way as an `explain-architecture` report: inline CSS, Graphviz diagrams inlined as SVG, no scripts or CDNs. Follow these two files, and this one for what the review adds:

- [explain-architecture/references/report.md](../../explain-architecture/references/report.md) - the CSS scaffold, cards, tiles, tables, size bars, and print styles.
- [explain-architecture/references/diagrams.md](../../explain-architecture/references/diagrams.md) - diagram budgets, box roles and colors, the Graphviz header, rendering, and the screenshot check.

Graphviz handles graph-shaped diagrams; hand-built divs and inline SVG handle the more editorial visuals (mass diagrams, cross-sections). Mix the two - don't lean on one kind of diagram for everything, it'll start to look generic.

## Extra styles

Add these to the scaffold's `<style>` block:

```css
.box.gone { background: #fff1f2; border-color: #e11d48; color: #9f1239; text-decoration: line-through; }
.box.new { background: #ecfdf5; border-color: #059669; color: #064e3b; }
.leak { color: #dc2626; font-weight: 600; }
.b-strong { background: #d1fae5; color: #065f46; border: 0; }
.b-explore { background: #fef3c7; color: #92400e; border: 0; }
.b-spec { background: #e2e8f0; color: #334155; border: 0; }
.evidence { font-size: 0.8rem; color: #334155; }
.evidence li { margin-bottom: 0.2rem; }
```

Badges are `<span class="badge b-strong">Strong</span>`; the plain `.badge` serves as the dependency-category tag.

## Header

Repo name, date, and legend chips: `.box` = module, `.box.seam` = seam, `.box.core` = deep module or the one holding the state, `.box.gone` = deleted, `.box.new` = added or moved, `.leak` = leakage. No introduction paragraph - straight into the candidates.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the vocabulary from the SKILL.md glossary without ceremony.

Each candidate is one `<article class="card">`:

- **Title** - short, names the deepening (e.g. "Collapse the Order intake pipeline").
- **Badge row** - recommendation strength (`Strong` = `.b-strong`, `Worth exploring` = `.b-explore`, `Speculative` = `.b-spec`), plus a `.badge` tag for the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files** - monospaced list in `<code>`.
- **Evidence** - `<ul class="evidence">`, one item per fact: churn counts, complaint quotes, test-to-interface mismatches.
- **Before / After diagram** - the centrepiece. Two columns, side by side (`.split` with `grid-template-columns: 1fr 1fr`). See patterns below.
- **Problem** - one sentence. What hurts.
- **Solution** - one sentence. What changes.
- **Wins** - bullets, <=6 words each. e.g. "Tests hit one interface", "Pricing logic stops leaking", "Delete 4 shallow wrappers".

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Mix them. Don't make every diagram look the same - variety is part of the point.

### Mass diagram (deep vs shallow)

Hand-built div stack, one column per module. Height ~ implementation size, width ~ interface size. A deep module is a tall narrow slab; a shallow module is a short wide slab. Color by role: implementation slate-800 (`#1e293b`), interface amber-200 (`#fde68a`). Great for "look how much interface this thing has for how little it does".

### Call graph

Graphviz, `rankdir=LR`, one `.dot` file for before and one for after, shown side by side. Nodes are modules; edges are calls. Dashed nodes for candidate seams; red edges for leaks; `gone` and `new` roles for what the deepening deletes and adds. Best for showing "before: everyone talks to everyone; after: they all go through one deep module".

### Sequence

A numbered flow, as described in `diagrams.md`. Best for showing that a shallow module just delegates the whole conversation to something behind it - the numbered hops *are* the diagram of the delegation.

### Adapter split

Hand-built SVG. Two columns of the same interface, drawn as identical shapes, feeding two different implementations. Emphasises that the *interface* is the deep thing and the *adapters* are the shallow interchangeable bits.

### Deletion test

Two columns:

- **left**: the module + its callers, complexity distributed across everything
- **right**: the module deleted, complexity concentrated somewhere else (the good case) OR complexity vanished (the module was a pass-through)

Text callout with the verdict.

## Top recommendation

One card, sits at the bottom. Contains:

- The candidate you'd tackle first
- Two-sentence rationale - why *this one* first, before the others
- The next concrete step (usually: "run `grill-me` on this candidate to nail down the interface")
