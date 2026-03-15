---
name: Document Repository
interaction: chat
description: Update or create README.md, ARCHITECTURE.md, and AGENTS.md.
opts:
  alias: document-repo
  auto_submit: false
  is_slash_cmd: true
  stop_context_insertion: true
---

## user

Update or create repository-level documentation. Review the current state of README.md, ARCHITECTURE.md, and AGENTS.md. Update them to accurately reflect the codebase. If a file is missing and the project clearly needs it, create it. If a file is already accurate, leave it alone.
