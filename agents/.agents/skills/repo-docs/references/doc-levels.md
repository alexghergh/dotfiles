# Documentation Levels

## High-level

Use this level when the user wants to understand:
- what the project is
- how to set it up and run it
- the top-level folder structure
- the main subsystems

Typical files:
- `README.md`
- top-level docs landing pages

Good output:
- a short project summary
- a quick setup or run path
- a brief repo map
- how to run the project as a user
- links to deeper docs instead of duplicating them

Too detailed:
- function-by-function explanation
- internal helper behavior
- long API tables that belong elsewhere

## Mid-level

Use this level when the user wants to understand:
- component boundaries
- pipelines or request flows
- input and output contracts
- diagrams or design notes

Typical files:
- `ARCHITECTURE.md`
- `docs/architecture/*.md`
- UML diagrams or other flow diagrams

Good output:
- component responsibilities
- stable design constraints
- pipeline summaries
- interface contracts

Too detailed:
- every helper function
- line-by-line control flow
- inline code commentary copied into repo docs

## Low-level

Use this level only when the user explicitly asks for it.

Typical targets:
- docstrings
- inline comments
- module docs

Default action:
- keep this out of repo docs
- use code-focused documentation instead

## Calibration cues

- if the user says "too detailed", move one level up or compress subsections
- if the user says "not detailed enough", move one level down or add component and pipeline detail
- if the right level is unclear, propose one level and one file mapping before editing
