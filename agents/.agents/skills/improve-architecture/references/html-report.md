# HTML Report Format

The architectural review is rendered as a single self-contained HTML file in the OS temp directory. Tailwind and Mermaid both come from CDNs. Mermaid handles graph-shaped diagrams reliably; hand-built divs and inline SVG handle the more editorial visuals (mass diagrams, cross-sections). Mix the two — don't lean on Mermaid for everything, it'll start to look generic.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review -- {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed seam lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Repo name, date, and a compact legend: solid box = module, dashed line = seam, red arrow = leakage, thick dark box = deep module. No introduction paragraph — straight into the candidates.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the vocabulary from the SKILL.md glossary without ceremony.

Each candidate is one `<article>`:

- **Title** — short, names the deepening (e.g. "Collapse the Order intake pipeline").
- **Badge row** — recommendation strength (`Strong` = emerald, `Worth exploring` = amber, `Speculative` = slate), plus a tag for the dependency category (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files** — monospaced list, `font-mono text-sm`.
- **Before / After diagram** — the centrepiece. Two columns, side by side. See patterns below.
- **Problem** — one sentence. What hurts.
- **Solution** — one sentence. What changes.
- **Wins** — bullets, <=6 words each. e.g. "Tests hit one interface", "Pricing logic stops leaking", "Delete 4 shallow wrappers".

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Mix them. Don't make every diagram look the same — variety is part of the point.

### Mass diagram (deep vs shallow)

Hand-built div stack, one column per module. Height ~ implementation size, width ~ interface size. A deep module is a tall narrow slab; a shallow module is a short wide slab. Color by role: implementation slate-800, interface amber-200. Great for "look how much interface this thing has for how little it does".

### Call graph

Mermaid `flowchart LR`. Nodes are modules; edges are calls. Dashed edges for candidate seams; red for leaks. Group by cluster: `subgraph "before" ... end` and `subgraph "after" ... end`. Best for showing "before: everyone talks to everyone; after: they all go through one deep module".

### Sequence

Mermaid `sequenceDiagram`. Best for showing that a shallow module just delegates the whole conversation to something behind it — the sequence *is* the diagram of the delegation.

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
- Two-sentence rationale — why *this one* first, before the others
- The next concrete step (usually: "run `grill-me` on this candidate to nail down the interface")
