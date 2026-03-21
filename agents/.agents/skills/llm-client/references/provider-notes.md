# provider notes

## default stance

For projects that mainly target OpenAI-compatible providers, prefer the `openai` package. It is a practical default for:

- OpenAI
- local OpenAI-compatible servers such as vLLM or LM Studio
- gateways and providers that expose an OpenAI-compatible endpoint

For maximum compatibility with OpenAI-style servers, the sample scripts in this skill use chat-completions style requests through the `openai` package.

Treat those scripts as compatibility-first examples, not as a recommendation that OpenAI-native projects should prefer chat completions over Responses.

For OpenAI-native projects, keep in mind that OpenAI now recommends the Responses API for new projects. Use that when the repo is clearly OpenAI-first and wants OpenAI-native tools, stateful flows, or response items instead of plain chat messages, and keep the repo-facing client contract stable while swapping the transport underneath it.

The Python examples in this skill are drafting material, not the required final file layout. The assembled example shows the default target: one repo-local `LLMClient` file. The pieces file exists only so the agent can borrow fragments before folding them into that final file.

## anthropic

Anthropic has a native Messages API with strong support for multiple images and file blocks. Claude also supports a Files API, and Anthropic now offers an OpenAI-compatible endpoint for core chat-completions flows.

Use Anthropic directly when:

- the repo already uses the Anthropic SDK
- the project depends on Claude-native features
- the user explicitly wants Claude-first code

Use an OpenAI-compatible Anthropic path only when the repo values compatibility over native features.

## gemini

Gemini is best treated as a separate provider, not as an OpenAI-compatible target. Its Python SDK uses `contents` and `parts`, and Google also has a Files API for uploaded media and documents.

Use Gemini directly when:

- the repo already uses `google-genai`
- file uploads or large multimodal documents are central to the workflow
- the user wants Gemini-native features instead of cross-provider compatibility first

## pydanticai

PydanticAI is worth considering when the user explicitly wants:

- provider swapping with a common agent-style interface
- a path toward typed outputs or tool calling
- more structure than a thin client wrapper

It is heavier than a simple repo-local client module, so do not introduce it by default. Keep it as an example or optional integration path.

The sample script in this skill only shows a provider-swappable text agent. If the repo already uses Pydantic models, add typed outputs in the repo-local wrapper instead of assuming every project needs that extra layer.

## cross-provider rule

Keep the project-facing contract stable, and swap the provider adapter underneath it.

Good swap points:

- OpenAI-compatible thin client using the `openai` package
- Anthropic-native client using the Anthropic SDK
- Gemini-native client using `google-genai`
- optional PydanticAI wrapper when the user wants a higher-level abstraction
