# good vs bad

## good boundaries

Good:

- the final repo usually exposes one small client file instead of a spread of helper modules
- config, request shaping, and simple transport helpers are folded into that client unless the repo already has a strong local pattern
- the final client exposes simple `client.complete(...)` and `client.generate(...)` methods
- parsing lives in a separate module
- cache helpers live in a separate module
- repeated sampling and aggregation live in workflow code
- the rest of the project can call the client without knowing provider request shapes

Good text-only call site:

```python
raw_text = client.complete(system_prompt, user_prompt)
payload = parse_json_response(raw_text)
```

Good multimodal call site:

```python
result = client.generate(
    system_prompt=system_prompt,
    user_prompt=user_prompt,
    images=[diagram_png],
    files=[notes_md],
)
structured = parse_summary(result.text)
```

## bad boundaries

Bad:

- the client knows business schemas from one workflow
- the client decides majority vote policy
- the client owns cache directories and manifest formats
- the client exposes raw provider message arrays everywhere in the codebase

Bad over-coupling:

```python
release_notes = client.generate_release_notes_with_retry_and_consensus(
    repo_root=repo_root,
    diff_paths=diff_paths,
    output_dir=output_dir,
)
```

That is not a client anymore. It is workflow code wearing a client name.

## good growth path

Start small.

1. one final `LLMClient` with `LLMClientConfig`, `create_client(...)`, and `complete(...)`
2. add `generate(...)` when the repo actually needs images or small text-like files
3. borrow extra fragments from the pieces file only when the final client needs them
4. optional provider adapter layer or PydanticAI integration when multiple providers matter

## bad growth path

Do not front-load every abstraction because the repo might need it later.

- unnecessary request wrapper objects
- internal mini-frameworks
- generic plugin systems before a second provider exists
- one "universal" client that tries to hide every provider difference at once
