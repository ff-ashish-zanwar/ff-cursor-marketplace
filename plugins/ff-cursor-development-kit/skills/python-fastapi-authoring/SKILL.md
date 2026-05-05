---
name: python-fastapi-authoring
description: Author a FastAPI endpoint or job entry-point in a Python service
scope: rate-agent, qa-agent, rate-extraction-service, extraction-service
inherits: plan-and-implement
composes-rules: [layered-architecture, py-pydantic-v2-io, py-typed-exceptions, py-no-circular-imports, api-contract-first, json-schema-validation, typed-error-handling, error-envelope, structured-logging, testing-conventions, python-dep-tool-per-repo, ai-service-mode-polymorphism]
when-to-invoke: Adding a FastAPI endpoint or orchestration method in a Python AI service
sources:
  - rate-agent/.cursor/service-knowledge-base/coding-guidelines.md
  - qa-agent/.cursor/service-knowledge-base/coding-guidelines.md
  - rate-extraction-service/.cursor/service-knowledge-base/coding-guidelines.md
---
# python-fastapi-authoring

## Purpose
Author a FastAPI endpoint or job entry-point in a Python service. Detects per-repo dep tool (`uv` vs `pip`) and respects multi-mode execution (web / polling / job).

## 7 steps

### 1. Understand
Detect target repo. Note its dep tool from `service-cards/<repo>.md`:
- rate-agent / qa-agent → `uv` + `pyproject.toml`.
- rate-extraction-service / extraction-service → `pip` + `requirements.txt`.

Note the service's mode set (web / polling / job) if relevant.

### 2. Plan
- Pydantic request / response models.
- FastAPI route / dependency.
- Service layer function that takes a Pydantic model and returns one (works in all modes).
- Data-access module (GCS / Datastore / MySQL helper).
- Typed exceptions tied to the service's base exception.
- Tests under `tests/test_*.py`.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
Order: models → data-access → service → FastAPI route → tests. Add dependencies via the repo's tool; commit lockfile.

### 6. Self-check
- Pydantic at boundaries (no raw `dict` across modules).
- Typed exceptions; no bare `except:`.
- LLM calls (if any) go through the abstraction; token budget pre-check present.
- Prompts (if any) live in `prompts/`.
- Logging uses the service's JSON logger with `task_id` / `correlationId`.
- Lockfile (`uv.lock` or `requirements.txt`) updated and committed.

### 7. Cleanup / regression
`pytest`; `ruff check`; `black --check` (or the repo's equivalent).

## Related
- Skills: `llm-prompt-authoring`, `datastore-kind-change`, `event-contract-authoring`.
- Agents: `architecture-agent`, `prompt-review-agent`.
