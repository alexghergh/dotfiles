---
name: Combine Plans
interaction: chat
description: Integrate another agent's plan into the current one.
opts:
  alias: combine-plans
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Here is another agent's implementation plan for the same change. Review it against your own plan. Take the strongest points from it, integrate them into yours, and re-draft a single combined plan. Where the plans conflict, pick the better approach and explain why.
