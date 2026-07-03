---
name: handoff
description: Write a self-contained implementation brief for a brand-new session, so a fresh agent with no prior context can pick up the work. Use whenever the user says "handoff", "hand this off", "write a handoff", "chat handoff", "file handoff", "save this session", or when a long session is about to end and continuity matters. Argument decides destination — no arg or `file` writes a file, `chat` outputs in chat only.
argument-hint: "chat | file (default)"
---

# Handoff

Write a self-contained implementation brief that can be pasted as the first user message in a brand-new session.

Assume the new session has no prior context, no access to this chat, and no hidden memory. The brief must stand entirely on its own.

## Voice and framing

- **Second-person imperative.** Example style: "You are implementing X. The next step is Y."
- **No past-tense narrative.** Do not describe what "we" did.
- **No context-implying phrases.** Do not say "we", "our conversation", "this chat", "as discussed", "above", "earlier", "continue", "pick up where we left off", or anything else that implies prior-session context.
- **A clean working brief, not a recap.** The reader is starting fresh; give them a task, not a summary.

## Structure — exactly these seven sections in this order

Use markdown `#` headers for section titles. The seven sections and their content:

- `# Goal` — what is being built, changed, or fixed, and why, in 1-2 sentences.
- `# Current state` — what is done, what is in progress, what is not started.
- `# Key decisions` — constraints and reasoning, written as directives ("Use X because Y").
- `# Files touched` — path and one-line description per relevant file changed so far.
- `# Open questions` — unresolved ambiguities that need answers before proceeding.
- `# Next steps` — ordered, concrete actions the next session can take immediately.
- `# Risks` — important failure modes, assumptions, or verification gaps.

## Output rendering

- **Chat mode** — wrap the entire brief in a fenced `md` code block so the reader can copy the raw markdown out without rendered headers getting in the way. Shape:

````
```md
# Goal
...

# Current state
...
```
````

  If the brief itself contains triple-backtick fences (e.g., a shell command in `# Next steps` or a code snippet in `# Files touched`), use a longer outer fence (four or more backticks) so the inner fences don't terminate the wrapper early.

- **File mode** — write the raw markdown directly to the `.md` file. No fence wrapper (the file already has the `.md` extension).

## Content rules

- Prefer concrete facts, constraints, and instructions over chronology.
- Name files, components, commands, and interfaces when relevant.
- Reference existing artifacts by path or URL instead of duplicating them. If a plan already lives at `docs/plans/foo.md`, link to it — do not paste it in.
- If something is uncertain, label it `unverified`.
- If a section has nothing to report, write `none`.
- Include no preamble, no closing commentary.
- Redact sensitive information: API keys, passwords, PII, session identifiers. Replace with `[REDACTED]`; note in general terms what was there.

## Output destination

The user's argument decides where the brief goes. Interpret their phrasing for intent, not just a literal token: "write me a handoff to chat" / "just show me the handoff" → chat mode; "write a handoff" / "save a handoff" / "file handoff" → file mode.

- **No argument, or `file`** — write to `~/.agents/handoffs/handoff-YYYY-MM-DD-<short-title>.md`. The `<short-title>` is a slug derived from the goal: lowercase, hyphens between words, no spaces or special characters, ~40 chars max (e.g., "refactor payment gateway" → `refactor-payment-gateway`). If the target file already exists, pick a distinct name. After writing, output **only** the handoff file path — nothing else.
- **`chat`** — output the brief inline in chat only. Do not write a file.

## After writing (file mode)

Print only the handoff path. No summary, no next-step suggestions in the chat body. The file itself is the artifact.

## Length

A handoff is a distillation, not a transcript. Include:

- Every decision that constrains what comes next
- Every state a fresh agent needs to reconstruct
- Every open question that's still open

Exclude chit-chat, rabbit holes that didn't affect the outcome, rejected alternatives (unless the rejection reason matters going forward), and anything already in a linked artifact. If in doubt, cut.
