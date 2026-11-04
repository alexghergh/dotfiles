---
name: explain-architecture
description: Explain how a codebase, subsystem, or request path is put together, as a diagram-led HTML report that also prints to PDF. Describes the code as it is, without proposing changes. Use when the user asks to explain, map, draw, or diagram the architecture, asks how a part of the system works or how a request flows through it, or wants an overview of a repo for someone new to it.
allowed-tools: Agent Read Grep Glob Bash Write
---

# Explain Architecture

Explain how code is put together to a reader who has not seen it. The report describes; it does not judge. When the user wants changes proposed, that is `improve-architecture`. If you notice problems while exploring, list them in chat after the report, never inside it.

## 1. Scope and reader

Settle two things before exploring: what the report covers (the whole repo, one subsystem, or one flow) and who reads it (the user, a new contributor, someone outside engineering). When the request leaves either open, ask once, with a recommended answer.

## 2. Explore

Read the entry points, the build and config files, and the main modules; for a large repo, send `Explore` sub-agents per area. For each part, note what it owns, its files, what it calls, and what calls it. Pick one to three paths worth tracing end to end, such as the life of a request, a write, or startup.

Ground every box and arrow in code you read: a box names real paths, and an arrow is a call, import, message, or data write you saw. Do not infer relationships from names alone.

## 3. Plan the diagrams

- An overview of the whole scope.
- A detail diagram for each area that needs one.
- A numbered flow for each traced path.

Each diagram follows the budget and rules in [references/diagrams.md](references/diagrams.md). Show the user the planned list, one line per diagram, and wait for a go-ahead before drawing; for a single-flow report, go straight on.

## 4. Build the report

Work in `/tmp/claude/architecture/<slug>/`: one `.dot` file per diagram, rendered with `dot -Tsvg_inline <name>.dot -o <name>.svg`, and a `report.src.html` that follows [references/report.md](references/report.md), with a `<!-- svg: <name> -->` marker where each diagram goes. Then inline the diagrams:

```bash
python3 <this skill>/scripts/assemble.py /tmp/claude/architecture/<slug>/report.src.html /tmp/claude/architecture/<slug>/report.html
```

Text taken from the repo goes into the HTML with `<`, `>`, and `&` escaped.

## 5. Check

1. Screenshot the report as described in [references/diagrams.md](references/diagrams.md#check-what-you-drew), read the image, and fix what it shows.
2. Confirm every path in the report exists.
3. Give the reader test to a fresh sub-agent: only the report text and the reader description, no tools. Ask it to explain in its own words what the system does and how the traced paths run, and to list every term it could not understand from the report alone. Fix the gaps it finds.

Open the report with `xdg-open` and print its absolute path. For a PDF, print from the browser; the report's print styles lay it out on A4. Do not copy the report anywhere else yourself.
