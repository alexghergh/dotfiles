# selection guide

## choose the final shape first

Do not default to a "future-proof" client if the project does not need it.

Most repos should end up with one repo-local `LLMClient` file that contains:

- `LLMClientConfig`
- `create_client(...)`
- `client.complete(...)`

The assembled example in this skill is intentionally text-only. Treat that as the default starting point.

The pieces file in this skill is drafting material for optional additions such as `generate(...)`, richer result types, or multimodal helpers. Borrow only the fragments you need, then fold them into the final client file unless the repo already has a strong reason to keep a second file.

Choose `complete(...)` only when:

- the project only sends text prompts
- images and local file inputs are out of scope
- the code mostly wants `client.complete(system_prompt, user_prompt)`
- returning raw provider payloads is not important

Add `generate(...)` when:

- the project needs multiple images in one call
- small text-like file inputs are part of the workflow
- the caller needs access to raw response payloads
- the repo may need to swap among OpenAI-compatible endpoints while keeping the same public shape

## do you need both methods

Usually no.

- start with `client.complete(...)`
- add `client.generate(...)` when images or files show up

Keep them on the same final `LLMClient` when the repo benefits from one stable client boundary.

## images and small text-like files without over-engineering

For broad OpenAI-compatible support, "file input" in this skill should usually mean one of these:

- image files converted to image content blocks
- text-like files inlined into the user message with filename context

Do not assume a generic cross-provider binary upload API exists. Native file APIs differ across OpenAI, Anthropic, Gemini, and local OpenAI-compatible servers.

Keep those inputs small and application-controlled. If the files are large, user-supplied, or security-sensitive, switch to provider-native upload APIs or a repo-local ingestion layer instead of inlining bytes from disk.

## if unsure, ask the user

Ask one direct question:

- "Should the final client expose only `complete(...)`, or both `complete(...)` and `generate(...)`?"
