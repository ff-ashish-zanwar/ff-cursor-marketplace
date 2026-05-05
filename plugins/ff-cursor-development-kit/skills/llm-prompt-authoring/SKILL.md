---
name: llm-prompt-authoring
description: Author a prompt that is versioned, tested, and wrapped by the service's LLM abstraction
scope: rate-agent, qa-agent, quote-ai-backend
inherits: plan-and-implement
composes-rules: [ai-llm-abstraction-layer, ai-prompts-as-constants, ai-token-budget, llm-vendor-per-service, prompt-governance, no-pii-in-logs, py-pydantic-v2-io, typed-error-handling]
when-to-invoke: Authoring or editing an LLM prompt used in an AI service
sources:
  - rate-agent/.cursor/service-knowledge-base/coding-guidelines.md
  - qa-agent/.cursor/service-knowledge-base/coding-guidelines.md
  - quote-ai-backend/.cursor/architecture.md
---
# llm-prompt-authoring

## Purpose
Author a prompt that is versioned, tested, and wrapped by the service's LLM abstraction. Vendor is determined per service by `llm-vendor-per-service`.

## 7 steps

### 1. Understand
Identify the call site + current vendor (rate-agent → Gemini; qa-agent → Azure OpenAI; quote-ai-backend → mixed). Note the output shape the caller expects (typed Pydantic model or typed Go struct).

### 2. Plan
- File location: `prompts/<name>.py` or `prompts/<name>.ts` / `.go`.
- Shape: Role / Context / Task / Constraints / Output. The Output section declares the JSON schema the model must return.
- Substitution: bounded placeholders; all runtime inputs validated before substitution.
- Token budget: estimate; if variable, wire up `ai-token-budget` pre-check.

### 3. Propose
Prompt draft + vendor + input validation + expected output schema.

### 4. Pause for human approval

### 5. Implement
Add prompt constant. Write a typed wrapper function that:
- Validates inputs.
- Checks token budget.
- Calls the LLM via the abstraction.
- Parses output against the declared schema; raises `TokenBudgetExceeded` / `LLMSchemaError` on failure.

### 6. Self-check
- Prompt file has no inline customer data / tokens.
- R/C/T/C/O sections complete and distinct.
- Output section declares the schema explicitly.
- Vendor unchanged (per ADR-05) unless accompanied by an ADR-05 amendment.
- Logging captures model, token counts, latency, prompt hash — never prompt text.

### 7. Cleanup / regression
Unit test using a recorded sample input; assert the output parses against the schema.

## Related
- Skills: `python-fastapi-authoring`, `go-gin-api-authoring`.
- Agents: `prompt-review-agent`, `adr-compliance-agent`.
