"""Assembled one-file example of a repo-local text-only LLMClient.

This is the default pattern the skill should produce in a target repo: one file
that holds config, transport setup, and a small public client surface together.
"""

from dataclasses import dataclass
from typing import Any, Optional


@dataclass(frozen=True)
class LLMClientConfig:
    """Configuration for an OpenAI-compatible LLM client."""

    model: str
    api_key: Optional[str] = None
    base_url: Optional[str] = None
    reasoning_effort: Optional[str] = None
    temperature: float = 0.2
    timeout_seconds: float = 300.0


def validate_config(config: LLMClientConfig) -> LLMClientConfig:
    """Validate client configuration before building the SDK client."""
    if not config.model:
        raise ValueError("model must be provided")
    if config.temperature < 0:
        raise ValueError("temperature must be >= 0")
    if config.timeout_seconds <= 0:
        raise ValueError("timeout_seconds must be > 0")
    return config


def create_client(config: LLMClientConfig):
    """Create an OpenAI SDK client from shared configuration."""
    validate_config(config)

    try:
        from openai import OpenAI
    except ImportError as exc:
        raise RuntimeError("Install the 'openai' package to use this client") from exc

    client_kwargs: dict[str, object] = {"timeout": config.timeout_seconds}
    if config.api_key is not None:
        client_kwargs["api_key"] = config.api_key
    if config.base_url is not None:
        client_kwargs["base_url"] = config.base_url
    return OpenAI(**client_kwargs)


def request_options_from_config(config: LLMClientConfig) -> dict[str, object]:
    """Build request options shared by client methods."""
    options: dict[str, object] = {
        "model": config.model,
        "temperature": config.temperature,
    }
    if config.reasoning_effort is not None:
        options["reasoning_effort"] = config.reasoning_effort
    return options


def resolve_text_from_chat_completion(completion: Any) -> str:
    """Extract text from a chat-completions style response."""
    if not getattr(completion, "choices", None):
        raise ValueError("LLM returned no choices")

    message = completion.choices[0].message
    content = message.content or ""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for item in content:
            if isinstance(item, dict):
                text = item.get("text")
            else:
                text = getattr(item, "text", None)
            if text:
                parts.append(text)
        return "\n".join(parts)
    return str(content)


class LLMClient:
    """One-file text client with a small public surface."""

    def __init__(self, config: LLMClientConfig) -> None:
        self._config = validate_config(config)
        self._client = create_client(self._config)

    @property
    def model(self) -> str:
        return self._config.model

    def _request_options(self) -> dict[str, object]:
        return request_options_from_config(self._config)

    def complete(self, system_prompt: str, user_prompt: str) -> str:
        """Send a text-only request and return plain text."""
        if not system_prompt:
            raise ValueError("system_prompt must be non-empty")
        if not user_prompt:
            raise ValueError("user_prompt must be non-empty")

        request: dict[str, object] = {
            **self._request_options(),
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        }
        completion = self._client.chat.completions.create(**request)
        return resolve_text_from_chat_completion(completion)
