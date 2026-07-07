---
name: research
description: Ground a claim in evidence before answering, by reading local code, searching the web, or running a probe — as much as the question actually needs. Use when the user says "research this first before implementing", "look this up", "verify how X actually works", "check what version of X we have", "confirm this before we build". Also invoke proactively when (a) the user pastes a URL as the source of truth for their question — fetch it, do not summarize from memory; (b) the question is an enumeration ("which X are there", "any other Y", "list the Z", "what options does Z have") — memory is unreliable for lists; (c) you catch yourself writing any hedge — "I think", "usually", "typically", "should be", "fair warning", "from what I remember", "IIRC", "roughly", "off the top of my head", "I believe", "as far as I know", "someone please double-check but" — the hedge is the failure signal; delete it and fetch the source.
allowed-tools: WebSearch WebFetch Read Grep Glob Bash
---

# Research

The failure mode this skill prevents is **answering from memory on things you could have checked in ten seconds**. Library APIs, framework behavior, plugin internals, version-specific quirks, config schemas — these get answered wrong by pattern-matching against training data instead of reading the code that's right there on disk.

Rule: if the claim is falsifiable and the source is reachable, verify before answering.

## Scale to the question

Not every question needs a full loop. Match effort to the ask:

- **Trivial** — "what version of X do we have?" — one lookup, answer.
- **Small** — "how does this function handle empty input?" — read the function, answer with a cite.
- **Medium** — "does this plugin's ACP handler support session/load?" — read a few related files, maybe one web search for spec.
- **Real** — "how does this framework's async runtime interact with our worker pool?" — multiple files + docs + probe to drive real code paths, as static reading alone might not be enough.

Do enough to be right. Do not over-invest in trivia. Do not skip the read just because pattern-matching feels sufficient.

## Three sources

Use whichever ones the question requires — often just one or two.

### Local code

The user's code and any imported library code you have read access to. Read the actual source, not a mental model of the source. Cite `path/to/file.ext:line` for load-bearing claims.

Where library code lives:
- Python: `.venv/lib/python*/site-packages/<pkg>/`, `~/.local/lib/python*/site-packages/<pkg>/`
- Node: `node_modules/<pkg>/`
- Rust: `~/.cargo/registry/src/**/<pkg>-*/`
- Go: `$GOPATH/pkg/mod/<pkg>@*/`
- Neovim plugins: `~/.local/share/nvim/lazy/<plugin>/`, `~/.local/share/nvim/site/pack/*/start/<plugin>/`
- System libs (headers): `/usr/include/`, `/usr/local/include/`

If the library isn't installed locally, say so — do not guess based on the README.

### Web

`WebSearch` and `WebFetch`. Priority order:
1. Official docs for the project
2. The project's own repository (README, source, changelog)
3. Release notes for the version installed locally
4. GitHub issues / PRs for edge cases and known bugs
5. Established secondary sources — only when primary doesn't answer

Web evidence may be dated. If the local install is version X and the docs describe version Y, that's a **version-skew** finding, not a contradiction — call it out.

### Probes (main agent only)

When the question depends on runtime behavior, write and run a short script that answers it. Sub-agents cannot execute; only the main agent runs probes.

Good candidates:
- "Does `os.listdir` return sorted output on this filesystem?" — 3-line Python.
- "What does this Lua function receive when stdout is binary?" — minimal nvim `--headless` script.
- "Does this tree-shaker drop the unused import?" — build + inspect output.

Skip probes when the question is architectural / opinion-based, when the behavior is fully documented and version-stable, or when the probe would have side effects you can't sandbox (deletes data, hits paid APIs, mutates shared state).

If the codebase and web agree but the probe disagrees, the probe wins.

## Handling contradictions

- Codebase vs. web docs → often version-skew. Report both, name the versions.
- Two web sources disagree → cite both, note which is primary.
- Probe disagrees with sources → probe wins, but the disagreement is worth surfacing so the user knows the documented behavior was wrong. Make sure first the disagreement is real, as opposed to your inference being wrong based on just statically reading code.

Don't paper over disagreements — they're often the actual finding.

## Sub-agent delegation

Optional, not required. Local-code reads and web searches can be delegated to a sub-agent when parallelising helps; probes cannot (sub-agents can't execute code). If the question is small enough to answer in one or two file reads, don't bother with delegation — inline is faster.

## Output

Answer the user directly. Cite the specific source for each load-bearing claim as a path or URL. No tables, no confidence markers, no "here's my research process" preamble. If sources contradicted or the local install is version-skewed vs. the docs, mention it in one sentence.

If the evidence isn't reachable — the library isn't installed, the docs are gated, the runtime isn't available — say so plainly, name what you tried, and offer the closest available answer with the caveat.

Do not write any files.
