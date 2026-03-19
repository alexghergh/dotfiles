---
name: Implementation Plan
interaction: chat
description: Structured planning with scope, phases, affected files, risks, and acceptance criteria.
opts:
  alias: implementation-plan
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Help me plan the implementation of the following change. Do not write or edit any files.

Start with a quick targeted scan of the most relevant code paths. Ask all blocking clarifying questions at once before deeper exploration. Once I answer, inspect the relevant areas as needed and produce a plan covering: scope (included and excluded), ordered phases with affected files and dependencies between them, risks with mitigation, and how to verify the change is correct.

Do not implement anything until I explicitly approve the plan.
