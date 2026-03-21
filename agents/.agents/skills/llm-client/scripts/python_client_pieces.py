"""Reference pieces to fold into a repo-local LLM client file.

These snippets are drafting material for the skill. Copy and merge the pieces
you need into the final client file instead of preserving this file split by
default.
"""

import base64
import mimetypes
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Optional

TEXT_LIKE_MIME_TYPES = {
    "application/json",
    "application/ld+json",
    "application/xml",
    "application/x-yaml",
    "application/yaml",
    "text/csv",
    "text/markdown",
}


@dataclass(frozen=True)
class LLMClientConfig:
    """Configuration for an OpenAI-compatible LLM client."""

    model: str
    api_key: Optional[str] = None
    base_url: Optional[str] = None
    reasoning_effort: Optional[str] = None
    temperature: float = 0.2
    timeout_seconds: float = 300.0


@dataclass(frozen=True)
class LocalInputPolicy:
    """Rules for loading local files into multimodal requests."""

    allowed_roots: tuple[Path, ...] = ()
    max_bytes: Optional[int] = None


@dataclass(frozen=True)
class ImageInput:
    """An image attachment for multimodal requests."""

    data: bytes
    mime_type: str
    name: Optional[str] = None


@dataclass(frozen=True)
class FileInput:
    """A file attachment for multimodal requests."""

    name: str
    data: bytes
    mime_type: str


@dataclass(frozen=True)
class LLMResult:
    """A normalized result for richer client calls."""

    text: str
    raw: Any
    model: Optional[str] = None
    usage: Optional[dict[str, Any]] = None


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


def infer_mime_type(path: str | Path) -> Optional[str]:
    """Infer a MIME type from a filesystem path."""
    mime_type, _ = mimetypes.guess_type(str(path))
    return mime_type


def resolve_local_path(path: str | Path, input_policy: LocalInputPolicy) -> Path:
    """Resolve a local path and apply optional policy checks."""
    resolved = Path(path).expanduser().resolve()

    if input_policy.allowed_roots:
        normalized_roots = tuple(root.expanduser().resolve() for root in input_policy.allowed_roots)
        if not any(resolved.is_relative_to(root) for root in normalized_roots):
            raise ValueError("Path is outside the allowed roots")

    if input_policy.max_bytes is not None and resolved.stat().st_size > input_policy.max_bytes:
        raise ValueError(f"File exceeds max_bytes: {resolved}")

    return resolved


def load_image_input(
    path: str | Path,
    *,
    input_policy: LocalInputPolicy,
    mime_type: Optional[str] = None,
) -> ImageInput:
    """Load an application-controlled image path into an ImageInput."""
    resolved = resolve_local_path(path, input_policy)
    detected_mime = mime_type or infer_mime_type(resolved)
    if not detected_mime or not detected_mime.startswith("image/"):
        raise ValueError(f"Expected an image path, got MIME type: {detected_mime!r}")
    return ImageInput(
        data=resolved.read_bytes(),
        mime_type=detected_mime,
        name=resolved.name,
    )


def load_file_input(
    path: str | Path,
    *,
    input_policy: LocalInputPolicy,
    mime_type: Optional[str] = None,
) -> FileInput:
    """Load an application-controlled file path into a FileInput."""
    resolved = resolve_local_path(path, input_policy)
    detected_mime = mime_type or infer_mime_type(resolved) or "application/octet-stream"
    return FileInput(
        name=resolved.name,
        data=resolved.read_bytes(),
        mime_type=detected_mime,
    )


def dump_response(response: Any) -> Any:
    """Return a serializable form of an SDK response when possible."""
    for method_name in ("model_dump", "dict", "to_dict"):
        method = getattr(response, method_name, None)
        if callable(method):
            return method()
    return str(response)


def extract_usage(response: Any) -> Optional[dict[str, Any]]:
    """Return usage metadata when the SDK provides it."""
    usage = getattr(response, "usage", None)
    if usage is None:
        return None
    raw_usage = dump_response(usage)
    if isinstance(raw_usage, dict):
        return raw_usage
    return {"raw": raw_usage}


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


def image_to_content_block(image: ImageInput) -> dict[str, Any]:
    """Convert an image input to an OpenAI-compatible image block."""
    image_b64 = base64.b64encode(image.data).decode("ascii")
    data_url = f"data:{image.mime_type};base64,{image_b64}"
    return {"type": "image_url", "image_url": {"url": data_url}}


def text_to_content_block(text: str) -> dict[str, str]:
    """Convert plain text to a content block."""
    return {"type": "text", "text": text}


def file_to_inline_text(file_input: FileInput) -> str:
    """Render a small text-like file as inline user content."""
    mime_type = file_input.mime_type.lower()
    if not (mime_type.startswith("text/") or mime_type in TEXT_LIKE_MIME_TYPES):
        raise ValueError(
            "Only text-like files can be inlined generically. "
            f"Unsupported MIME type: {file_input.mime_type}"
        )
    try:
        decoded = file_input.data.decode("utf-8")
    except UnicodeDecodeError:
        decoded = file_input.data.decode("utf-8", errors="replace")
    return (
        f"attached file: {file_input.name}\n"
        f"mime type: {file_input.mime_type}\n\n"
        f"{decoded}"
    )
