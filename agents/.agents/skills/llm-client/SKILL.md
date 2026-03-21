---
name: llm-client
description: Implement or refactor a reusable LLM client layer for text-only or multimodal projects. Use when a project needs one final repo-local client module, OpenAI-compatible provider support via the openai package, or guidance on keeping threading, caching, retry, and aggregation concerns outside the core client.
---

# LLM Client

Use this skill when the user wants one final repo-local client module with simple call sites and clear separation from orchestration code.

## Start from the target outcome

The skill files are drafting material. Do not copy them word-for-word, and do not preserve this skill's file layout in the target repo unless the repo already has a strong local convention that matches it.

The default outcome is one final repo-local client file in the repo's coding language. A second file is acceptable only when the repo already has that pattern or the logic is genuinely too large for one file.

## Read only what you need

- for the default outcome, start with the small text-only assembled example:
  - read [python_llm_client.py](scripts/python_llm_client.py)
- if the repo also needs multimodal inputs, richer result types, or file helpers, borrow only those fragments:
  - read [python_client_pieces.py](scripts/python_client_pieces.py)
- if you need help deciding whether the final client should expose `complete(...)`, `generate(...)`, or both:
  - read [selection guide](references/selection-guide.md)
- if you want boundary examples before coding:
  - read [good vs bad](references/good-vs-bad.md)
- if the user explicitly wants provider swapping or PydanticAI:
  - read [provider notes](references/provider-notes.md)
  - then read [python_pydanticai_example.py](scripts/python_pydanticai_example.py)
- if the user asks about threading, caching, retry, repeated sampling, or aggregation:
  - read [orchestration patterns](references/orchestration-patterns.md)

## Working rules

1. inspect the repo's current call sites before choosing a client shape
2. produce the final repo-local client module first, then borrow only the smallest set of pieces needed to draft it
3. treat the shared config and helper snippets as fragments to assemble and adapt, not as imports to preserve
4. keep business-specific parsing, caching, retries, and consensus logic outside the client
5. default to the `openai` package for OpenAI-compatible servers unless the project already uses another SDK
6. by default, collapse copied pieces into one final client file instead of scattering them across helper or util modules
7. start with `LLMClientConfig` plus `create_client(...)` and `complete(...)`, then add `generate(...)` only when the repo needs it
8. prefer repo-facing calls such as `client.complete(...)` and `client.generate(...)`
9. read only the files needed for the requested outcome; do not mechanically load every reference
10. preserve the repo's existing public client names and method shape when refactoring

## What this skill should produce

- one final repo-local client module in the repo's coding language, usually one file and at most a very small number of files
- modular logic inside that final module, not helper-file sprawl by default
- provider-specific translation hidden behind the client boundary
- drafting pieces and patterns, not a rigid template
