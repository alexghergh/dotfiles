---
name: Handoff Chat
interaction: chat
description: Produce a self-contained implementation brief for a brand-new session in chat.
opts:
  alias: handoff-chat
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Write a self-contained implementation brief that can be pasted as the first user message in a brand-new session.

Assume the new session has no prior context, no access to this chat, and no hidden memory. The brief must stand entirely on its own.

Write in second-person imperative. Example style: "You are implementing X. The next step is Y."
Do not write in past-tense narrative.
Do not mention "we", "our conversation", "this chat", "as discussed", "above", "earlier", "continue", "pick up where we left off", or any other phrase that implies prior-session context.

Present the result as a clean working brief, not as a recap or summary of a conversation.

Output only markdown. Include exactly these sections, in this order:

1. **Goal** — what is being built, changed, or fixed, and why, in 1–2 sentences
2. **Current state** — what is done, what is in progress, and what is not started
3. **Key decisions** — constraints and reasoning, written as directives such as "Use X because Y"
4. **Files touched** — path and one-line description per relevant file changed so far
5. **Open questions** — unresolved ambiguities that need answers before proceeding
6. **Next steps** — ordered, concrete actions the next session can take immediately
7. **Risks** — important failure modes, assumptions, or verification gaps

Requirements:
- prefer concrete facts, constraints, and instructions over chronology
- name files, components, commands, and interfaces when relevant
- if something is uncertain, label it `unverified`
- if a section has nothing to report, write `none`
- include no preamble and no closing commentary
- output the brief in chat only
