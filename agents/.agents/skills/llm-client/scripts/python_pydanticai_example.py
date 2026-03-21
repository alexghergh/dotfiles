"""Optional PydanticAI wiring for projects that want a heavier abstraction."""

from dataclasses import dataclass
from typing import Literal, Optional

ProviderName = Literal["openai", "openai-compatible", "anthropic", "gemini"]


@dataclass(frozen=True)
class PydanticAIConfig:
    """Configuration for building a provider-swappable PydanticAI agent."""

    provider: ProviderName
    model: str
    system_prompt: str = ""
    api_key: Optional[str] = None
    base_url: Optional[str] = None


def build_agent(config: PydanticAIConfig):
    """
    Build a provider-swappable text agent with PydanticAI.

    For the provider shorthands below, the matching environment variables should
    be configured:

    - openai -> OPENAI_API_KEY
    - anthropic -> ANTHROPIC_API_KEY
    - gemini -> GOOGLE_API_KEY

    This example stays text-only on purpose. Add typed outputs or tool wiring in
    the repo-local wrapper only if the project actually needs them.
    """
    from pydantic_ai import Agent

    if config.provider == "openai-compatible":
        if not config.base_url:
            raise ValueError("base_url is required for openai-compatible mode")
        from pydantic_ai.models.openai import OpenAIChatModel
        from pydantic_ai.providers.openai import OpenAIProvider

        model = OpenAIChatModel(
            config.model,
            provider=OpenAIProvider(
                base_url=config.base_url,
                api_key=config.api_key,
            ),
        )
        return Agent(model, instructions=config.system_prompt)

    provider_model = {
        "openai": f"openai:{config.model}",
        "anthropic": f"anthropic:{config.model}",
        "gemini": f"google-gla:{config.model}",
    }[config.provider]
    return Agent(provider_model, instructions=config.system_prompt)


def run_text(agent, prompt: str) -> str:
    """Run a synchronous text request through a PydanticAI agent."""
    result = agent.run_sync(prompt)
    return str(result.output)
