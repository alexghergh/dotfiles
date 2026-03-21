# orchestration patterns

These patterns are useful, but they should usually stay outside the core client.

## threading

If SDK thread safety is unclear, give each worker thread its own client instance and share only the immutable config.

Typical pattern:

- resolve config once
- create a thread-local pool
- let each worker fetch its client from the pool

```python
import threading

_thread_local = threading.local()


def get_client() -> LLMClient:
    client = getattr(_thread_local, "client", None)
    if client is None:
        client = LLMClient(config)
        _thread_local.client = client
    return client
```

## caching

Cache raw LLM responses, not parsed business objects.

A good cache key usually includes:

- prompt content
- model
- temperature
- reasoning effort
- document identity if the request depends on a specific file

A simple reusable pattern is to hash prompt plus config and store the raw response beside a small manifest of reproducibility metadata.

```python
cache_key = stable_hash(
    {
        "system_prompt": system_prompt,
        "user_prompt": user_prompt,
        "model": config.model,
        "temperature": config.temperature,
    }
)
result = client.generate(system_prompt=system_prompt, user_prompt=user_prompt)
write_json(cache_dir / f"{cache_key}.json", result.raw)
write_json(cache_dir / f"{cache_key}.manifest.json", {"model": result.model})
```

## retries

Keep retry logic close to the parser, not inside the transport wrapper.

Good retry reasons:

- invalid JSON
- malformed schema output
- parser-specific failures

Bad retry reasons:

- blindly retrying all transport failures forever
- mixing parse-retry policy into the client itself

```python
last_error = None
for _ in range(3):
    raw_text = client.complete(system_prompt, user_prompt)
    try:
        return parse_json(raw_text)
    except ValueError as exc:
        last_error = exc

raise last_error
```

## repeated sampling and aggregation

Repeated calls belong in orchestration code, not in the core client.

Useful aggregation patterns:

- majority vote on extracted items
- minimum count or ratio thresholds
- consensus ordering across repeated samples
- workflow-specific failure accounting

```python
samples = [parse_label(client.complete(system_prompt, user_prompt)) for _ in range(3)]
winner, count = Counter(samples).most_common(1)[0]
if count < 2:
    raise ValueError("no consensus")
return winner
```

## raw output manifests

If the project is pipeline-like or research-heavy, store enough metadata to reproduce the call:

- model
- temperature
- reasoning effort
- prompt hash
- workflow label
- timestamp

```python
manifest = {
    "model": config.model,
    "temperature": config.temperature,
    "reasoning_effort": config.reasoning_effort,
    "prompt_hash": stable_hash({"system": system_prompt, "user": user_prompt}),
    "workflow_label": workflow_label,
    "timestamp": now_iso8601(),
}
```
