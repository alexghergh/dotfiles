# Report

One self-contained HTML file: inline CSS and inline SVG, no scripts, no CDNs, no web fonts. It opens offline, nothing in it can run, and the print styles lay it out on A4.

## Structure

1. **Header**: the title; a meta line with the repo, commit (`git rev-parse --short HEAD`), date, and whatever else places the report (branch, versions, path prefix); legend chips for the box roles the diagrams use; a row of numbered links to the sections.
2. **Summary card**: three to five sentences on what the system does and how its parts divide the work, then two to four tiles with numbers that size it (files, lines in the largest module, entry points). Use only numbers you counted, and say in the tile what was counted.
3. **Overview**: the overview diagram in a card, with a notes column beside it: one bold label per point (for example **Entry**, **State**, **Outside the repo**) and a sentence or two each.
4. **One section per area**: a card with the detail diagram and its notes, then a parts table (part, path, what it owns).
5. **Traced paths**: per path, a card with the numbered flow and the numbered steps in the notes column.
6. **Size view**, optional: when the size of a module matters to the explanation, a bar of its lines split by concern, counted from the code.
7. **Terms**: only when the code uses project-specific names the reader needs; one line each.

A diagram more than about twice as wide as it is tall gets the card's full width, with its notes below it instead of beside it; in the side column its text shrinks too far to read. Every diagram has a caption saying what to look at. Prose stays short: if a note explains what the diagram already shows, cut the note or redraw the diagram.

## Scaffold

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{{scope}} - architecture</title>
<style>
  body { margin: 0; background: #fafaf9; color: #0f172a; font: 15px/1.55 system-ui, sans-serif; }
  main { max-width: 72rem; margin: 0 auto; padding: 3rem 1.5rem; }
  section { margin-top: 3.5rem; }
  h1 { font-size: 1.85rem; font-weight: 700; letter-spacing: -0.01em; margin: 0 0 0.5rem; }
  h2 { font-size: 1.5rem; font-weight: 600; margin: 0 0 1rem; }
  h3 { font-size: 1.05rem; font-weight: 600; margin: 0 0 0.5rem; }
  a { color: inherit; }
  .meta { font-size: 0.85rem; color: #475569; margin: 0 0 0.75rem; }
  .legend { display: flex; flex-wrap: wrap; gap: 0.6rem; align-items: center; font-size: 0.75rem; }
  nav { display: flex; flex-wrap: wrap; gap: 1rem; font-size: 0.75rem; color: #475569; margin-top: 0.75rem; }
  .card { background: white; border: 1px solid #e7e5e4; border-radius: 0.75rem; padding: 1.5rem; margin-bottom: 1rem; }
  .card > p:first-child { margin-top: 0; }
  .tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(12rem, 1fr)); gap: 1rem; margin-bottom: 1rem; }
  .tile { background: white; border: 1px solid #e7e5e4; border-radius: 0.75rem; padding: 1rem; }
  .tile .label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.04em; color: #64748b; }
  .tile .value { font-size: 1.5rem; font-weight: 700; }
  .tile .note { font-size: 0.75rem; color: #475569; }
  .split { display: grid; grid-template-columns: 3fr 2fr; gap: 1.5rem; align-items: start; }
  .notes { font-size: 0.85rem; color: #1e293b; }
  .notes p { margin: 0 0 0.75rem; }
  .notes ol { margin: 0; padding-left: 1.25rem; }
  .notes li { margin-bottom: 0.4rem; }
  figure { margin: 0; }
  figure svg { max-width: 100%; height: auto; }
  figcaption { font-size: 0.8rem; color: #475569; margin-top: 0.5rem; }
  code { font: 0.8em ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; background: #f1f5f9; padding: 0 0.2rem; border-radius: 0.2rem; }
  .box { display: inline-block; border: 2px solid #334155; border-radius: 0.5rem; padding: 0.1rem 0.5rem; background: white; }
  .box.core { background: #0f172a; color: #f8fafc; border-color: #0f172a; }
  .box.entry { background: #fff7ed; color: #7c2d12; border-color: #9a3412; }
  .box.surface { background: #fef3c7; border-color: #b45309; }
  .box.helper { background: #e2e8f0; border-color: #64748b; }
  .box.ext { background: #f1f5f9; color: #475569; border-color: #94a3b8; }
  .box.seam { border-style: dashed; }
  .badge { display: inline-block; padding: 0.1rem 0.55rem; border-radius: 9999px; font-size: 0.7rem; font-weight: 600; background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
  table.tl { width: 100%; border-collapse: collapse; }
  table.tl th { text-align: left; font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.05em; color: #57534e; padding: 0.4rem 0.55rem; border-bottom: 2px solid #d6d3d1; }
  table.tl td { vertical-align: top; padding: 0.4rem 0.55rem; border-bottom: 1px solid #e7e5e4; font-size: 0.8rem; }
  .bar { display: flex; height: 2.1rem; border-radius: 0.35rem; overflow: hidden; border: 1px solid #cbd5e1; }
  .bar div { display: flex; align-items: center; justify-content: center; font-size: 0.65rem; color: #f8fafc; white-space: nowrap; overflow: hidden; }
  @media print {
    @page { size: A4; margin: 14mm; }
    body { background: white; font-size: 10pt; }
    main { max-width: none; padding: 0; }
    nav { display: none; }
    h2 { break-after: avoid; }
    .card, .tile, table { break-inside: avoid; }
    .split { grid-template-columns: 1fr; }
  }
</style>
</head>
<body>
<main>
  <header>
    <h1>{{scope}}</h1>
    <p class="meta">{{repo}} at <code>{{commit}}</code>, {{date}}. {{anything else that places the report}}</p>
    <div class="legend">
      <span class="box">module</span>
      <span class="box core">holds the state</span>
      <span class="box entry">entry point</span>
      <span class="box ext">outside the repo</span>
    </div>
    <nav><a href="#overview">1. Overview</a> <a href="#area">2. {{area}}</a></nav>
  </header>

  <section id="summary">
    <div class="card"><p>{{what the system does}}</p></div>
    <div class="tiles">
      <div class="tile"><div class="label">{{what was counted}}</div><div class="value">{{n}}</div><div class="note">{{how}}</div></div>
    </div>
  </section>

  <section id="overview">
    <h2>1. Overview</h2>
    <div class="card split">
      <figure><!-- svg: overview --><figcaption>{{what to look at}}</figcaption></figure>
      <div class="notes"><p><b>{{label}}</b>: {{note}}</p></div>
    </div>
  </section>

  <section id="area">
    <h2>2. {{area}}</h2>
    <div class="card split">
      <figure><!-- svg: area-name --><figcaption>{{caption}}</figcaption></figure>
      <div class="notes"><ol><li>{{numbered step, or a note}}</li></ol></div>
    </div>
    <div class="card">
      <table class="tl">
        <tr><th>Part</th><th>Path</th><th>Owns</th></tr>
        <tr><td>{{name}}</td><td><code>{{path}}</code></td><td>{{responsibility}}</td></tr>
      </table>
    </div>
  </section>
</main>
</body>
</html>
```

A size bar is a `.bar` with one `<div>` per concern, `style="flex: <lines>; background: <color>"`, labeled with the concern and its line count.
