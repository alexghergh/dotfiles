---
name: brief-report
description: Write a short, self-contained report (at most 3-5 pages) on benchmarks, experiments, a design, or a research update, for a human reader who was not part of the work. Use when the user asks for a report, write-up, brief, or summary of results at the end of a working session or a background run, or types `/brief-report`.
argument-hint: "[topic or slug]"
---

# Brief report

Write a report on work done in this session, or by an agent the user set running (a benchmark, an experiment, a design study), for a person who saw none of it. The reader gets only the document: no chat, no logs, no code, no memory of earlier rounds. After one read they should know what question was asked, what was done, what came out, and how far to trust it.

"We" is allowed, but prefer the system, the setup, or the result as the subject. This is a description of a system and its measurements, not a research paper.

## Before writing

Settle these first:

1. Who reads it. Always ask the user; do not guess. Ask in one message: who the readers are (role, team), which field terms they use daily, and what they know about this project (nothing, the general design, earlier reports). Propose a concrete answer they can confirm or correct, e.g. "backend engineers on the storage team: they know what a cache and an eviction policy are, but not this benchmark or its results". The answer decides which terms need a definition and how much background to give.
2. The question the report answers, in one sentence. Ask when it is unclear.
3. The subject of study. Report on that subject, not on the machinery around it.

The third point is the most common failure. When the benchmarks measure a cache's eviction policy, the report covers how the policy behaves under the benchmark: what was varied, what was measured, what changed. How the service, the benchmark runner, or the policy is implemented stays out, unless the implementation _is_ the subject or one detail of it explains a result. The test for any implementation detail: would the reader's conclusions change without it? If not, cut it.

## Self-contained

- The session does not exist for the reader. No "as discussed", "as you asked", "the earlier fix", "this session", "the agent then", and no story of how the work went (reruns, bugs in the tooling, changes of plan) unless it affects how to read a result.
- Define, on first use and in plain words, every term the agreed reader does not already know; italicize it there. Names coined during the work (config names, variant nicknames, internal labels, tool names) always need it; no reader knows them. For a tool or component a result depends on, say what it does and why it helps before using its name. Prefer describing a thing over naming it; give it a name only if it recurs.
- The report stands alone, not as one part of a series. No "round 3", "part 2", or "as the last report showed". When earlier work matters, state its conclusions as context, with the evidence the reader needs to accept them.
- Do not explain what the reader already knows. Defining "cache eviction" for a team that runs storage services wastes their time and reads as if written for someone else; background covers only what this reader lacks.
- Code identifiers, paths, endpoints, and flags appear only when the reader needs them to reproduce a result or act on a recommendation. Never paste function signatures or tool schemas into the argument.
- State the setup concretely enough to judge the results: what was compared against what, on which data or workload, how many runs, the hardware or model when it matters, and what the metric means and its range.

## Structure: build the reader's understanding before the solution

The most damaging failure is a report that dives straight into the mechanism or the numbers, as if the reader had already talked the problem through with the author and agreed on it. A report shared with a team reaches people who did not. Before any design detail or result, the reader needs the same footing the author had when the work started.

There is no fixed template; choose sections that fit the content, and name each heading after what the section holds. Whatever the sections, the report covers these, in this order:

1. What the document is about and who it is for, in the first lines, followed by a short summary of the outcome written so that this reader can follow it.
2. The context: the system or setting involved, at the level this reader needs, and how it works today.
3. The problem: what goes wrong or what is missing, how it shows up, who it affects, and why it is worth the work. A reader who skips this cannot judge anything that follows.
4. What was considered: the options or approaches on the table, with the advantages and disadvantages of each, and why the chosen one won. A table often fits here. Include the obvious alternative a reader would raise, with the reason it lost.
5. What was done: the design, or the experiment setup and how it was scored.
6. What came out: results or the resulting design, the most important finding first, one finding per paragraph.
7. What the results do not show: limits, untested cases, what could change the conclusion. State these plainly, near the end or next to the result they qualify.
8. Recommendations or next steps, when the user wants them, as a short numbered list.

Scale each part to the reader: for readers who already know the system, context shrinks to a sentence; for readers new to it, context and problem can take a page. Each part needs only what came before it.

Length is at most 3-5 pages including figures; shorter is better when nothing is lost.

## Formatting: balance prose, tables, and figures

Assume the reader will not read a wall of text. Tables and figures are easier to scan and to remember than paragraphs, so prefer them for anything with a repeated shape, and keep prose for context, reasoning, and interpretation.

- A paragraph that compares three or more setups, options, or variants, or that carries more than two or three numbers, becomes a table with one or two sentences of context above it. The sentences say what was tested and why; the table holds the variants and what happened to each; a sentence below states what to take from it, if the table does not make that obvious.
- Keep prose paragraphs short: about five lines. A longer paragraph usually holds a list or a table.
- Use a table when the reader compares several items along the same columns: setups and scores, options and trade-offs, components and what they own. Keep cells short; put units in headers.

For example, this paragraph:

> Our design evicts the least recently used entries once the cache reaches 80% of its memory limit. We compared it with evicting the least frequently used entries, and with always pinning the configuration keys, which every request reads. The main question could not be answered: even with no pinning at all, the configuration keys never left the cache, because every request touches them and keeps them recent. What we could measure was small. Frequency-based eviction raised the hit rate on large product listings slightly (0.94 against 0.91), but median latency tied. Pinning showed no benefit, and after a deploy changed the configuration, the service kept serving the old pinned values until a restart.

reads better as:

> The cache drops entries once it reaches 80% of its memory limit. The test compared three ways of choosing which entries to drop. Configuration keys stayed cached in every variant, even without pinning, because every request reads them; so only smaller effects could be measured.
>
> | Entries dropped first | Hit rate on product listings | Median latency | Other effects |
> | --- | --- | --- | --- |
> | Least recently used (current) | 0.91 | tie | |
> | Least frequently used | 0.94 | tie | |
> | Least recently used, configuration keys pinned | no gain | tie | after a deploy changed the configuration, old values were served until a restart |
- Use a figure where it shows structure or trend better than text: a system diagram, the flow of one request, a score that changes with a parameter, a distribution across runs. Give each figure a caption saying what to look at, and the meaning of any highlight color. Generate figures with whatever is installed (graphviz, mermaid, matplotlib) and check that they render.
- Use a numbered list for ordered steps and recommendations, a bulleted list for a handful of parallel facts. Do not turn an argument into bullets.
- Every table and figure is introduced or interpreted by a sentence in the text; the text does not merely repeat what the table shows.
- Headings in sentence case. Bold only where a reader scanning the page needs an anchor, never as a label on every list item. No emojis, no ALL-CAPS emphasis, no arrows or unicode symbols in prose, no horizontal rules between sections.

## Honesty about results

- Never invent or fill in numbers, sample sizes, run counts, variance, dates, or citations. If a value is missing, say so or ask the user.
- Say how many runs each number comes from and how much a single run varies. Give intervals or spread for comparisons, and state the difference below which two setups count as a tie.
- A tie does not show that two setups are equivalent; it shows that this test could not tell them apart. Say how large a loss the test cannot rule out.
- Report null, negative, and surprising results, and questions the test could not answer.
- Keep "A happened alongside B" separate from "A caused B".
- Bound every conclusion to what was tested: this workload, this model, this hardware, this configuration. Say how the test conditions differ from real use.
- Do not round or select runs to make a result look cleaner.

## Signs of machine-written prose to remove

Structure matters more than wording; a relaxed or conversational voice is fine. These patterns are worth removing because they add words without adding facts:

- "Not X but Y" contrasts where nobody claimed X. State Y.
- One-line closers that repeat the paragraph, slogans added for effect, and sentences that announce what a table just showed. The report should not read like a blog post.
- Run-ups before the point ("Let's look at", "Here's the thing", "Notably,"), and arguments against objections nobody raised.
- Forced groups of three, and dashes used to join every pair of clauses.
- Inflated words: crucial, pivotal, key, robust (figurative), significant (unless statistical), seamless, powerful, underscores, highlights, showcases, delve, landscape.
- "Serves as", "stands as", "boasts", "features" instead of "is" and "has".
- Stacked hedges ("could potentially suggest"). Hedge only when the data calls for it, and say why.
- Writing about the document instead of its subject ("This report is organized as follows").
- A closing paragraph about the future or the importance of the work. End on the last concrete finding, limit, or recommendation.

Omit needless words, but never trim so far that the reader cannot reconstruct what was run, in what order, and how it was scored.

## Process

1. Gather the facts: result files, logs, the background agent's output, and the user's statements. Note each number with its source, and recompute any summary statistic the report states.
2. Pick a short slug for the topic and work in `/tmp/claude/reports/<slug>/`. Write the report as `<slug>.md`, with figures next to it.
3. Write the opening and the main finding first; if they do not fit in two short paragraphs, the question is not settled yet. Then draft the rest.
4. Revise against every rule in this file.
5. Reader test: give a fresh sub-agent only the report text (and figures) plus the agreed description of the reader, with no other context. Ask it to read as that reader and to:
   1. state the question and the main finding in two sentences;
   2. explain, in its own words, what the problem is, why it matters, and why the chosen approach beat the alternatives; if it cannot, the context, problem, or options parts are missing or too thin;
   3. list what context the report assumes the reader already has, and mark each item as known or not known to this reader;
   4. list every term, name, or acronym this reader could not understand from the text alone;
   5. list what the report explains that this reader already knows;
   6. point to any paragraph that is hard to take in at one read and would work better as a table, a list, or a figure;
   7. point out anything ambiguous, contradictory, or claimed without support.

   Tell it not to use tools or look for more context, and never to put the user's email address or other personal data into any request or file. Fix what it finds and repeat until it comes back clean.
6. Render a PDF when the tools are installed (for example `pandoc` to `.docx`, then `libreoffice --headless --convert-to pdf`), render the pages to images, and look at them: tables that split badly, figures too small to read, a page that is mostly white.
7. Tell the user the paths, anything left out or not verified, and the exact command to copy the report out if they are satisfied, for example `cp /tmp/claude/reports/<slug>/<slug>.pdf ~/Documents/`. Do not copy it anywhere yourself.
