---
name: calibrate-style
description: Re-calibrate AI prose style against the user's real output by mining transcripts and git history for AI-draft vs user-landed pairs, interviewing over them, and encoding the extracted rules into AGENTS.md exemplars and directives.md. Use when the user asks for a style calibration pass, when the same prose corrections ("trim this", "sounds non-human") start recurring again, or as the periodic refinement loop every few weeks.
allowed-tools: Read Grep Glob Bash Edit Write Skill
---

# Calibrate Style

Turn the user's real prose corrections into rules and exemplars, so style stops being re-litigated per session. The loop: mine authentic pairs, grill over them, test the calibration by rendering, then encode.

## Hard rules

- Landed text is not ground truth. Post-fight landed prose is usually the AI's skeleton with word swaps; only from-scratch user rewrites count as the target voice. When in doubt, ask the user to rewrite one artifact from scratch - that sample is worth more than ten landed ones.
- Privacy split: pairs mined from private repos never enter the public AGENTS.md verbatim. Reframe into an invented domain (config loader, uploader client, scheduler) keeping the failure pattern - never the text, names, or types.
- Extract rules, not adjectives. "Too verbose" is a symptom; the rule underneath is register, relevance, abstraction level, or a missing floor. Name the rule so a future draft can be checked against it.
- Recurrence threshold: a rule earns encoding only when the correction recurs across sessions; a cluster from one session is an incident, not a pattern.

## Phase 1: mine pairs

Sources, best first:

1. User messages quoting prose with an inline critique ("-> way too verbose", "-> this is so confusing"): the quote is the wrong side; the repo's current text is the landed side.
2. AI commit-message drafts vs `git log`: drafts live in `Write` calls to `/tmp/claude/msg.*.txt` inside transcripts, or inline in `git commit` commands; match to landed messages by subject or content.
3. Docstrings and comments the user reverted or rewrote (handoff notes often record "user rewrote X").

Transcripts are JSONL under `~/.claude/projects/<flattened-cwd>/`. Recipes:

    # typed user messages, dated; filter by message date, never file mtime
    # (resumed sessions carry old messages inside recently-touched files)
    jq -r 'select(.type=="user") | ((.timestamp // "?")[0:10]) + " " +
      (.message.content | if type=="string" then . elif type=="array"
       then ([.[] | select(.type?=="text") | .text] | join(" "))
       else "" end | gsub("\n"; " | "))' <project-dir>/*.jsonl

    # AI draft artifacts; swap .name / the file_path test as needed
    jq -r 'select(.type=="assistant") | .message.content[]? |
      select(.type?=="tool_use" and .name=="Write") |
      select(.input.file_path | test("msg\\.")) |
      .input.file_path + "\n" + .input.content' <project-dir>/*.jsonl

Traps: handoff and compaction summaries re-quote user messages, so raw grep counts are inflated - treat counts as signals and drop lines from "This session is being continued" summaries; history rewrites move commit dates, so search `git log` by subject or content, not by date window.

## Phase 2: interview

Invoke the grill-me skill over the pairs. Question shape: present one authentic A/B pair, point at the specific deltas, ask which delta is load-bearing and where the text first rings false. One pair per question, a recommendation attached. Keep a decision log of rules; supersede freely.

## Phase 3: calibration test

Render 3-5 fresh B-sides from code facts alone - never by editing the A side - across genres (commit body, docstring, comment). The user grades each and names the first sentence that rings false. Fold every correction back into the rule log and re-render if the misses were structural. Expect an asymptote, not 100%; stop when the user grades the batch as on target.

## Phase 4: encode

- Exemplars into the public AGENTS.md, privacy-reframed, one lesson per pair.
- Distilled rules into `~/.claude/directives.md` (re-injected every prompt). Rotation policy: the top current corrections live in directives.md; rules the model has internalized graduate into AGENTS.md prose; stale ones retire. Keep directives.md under ~15 lines.
- Propose the diffs one file at a time; the user approves each.
