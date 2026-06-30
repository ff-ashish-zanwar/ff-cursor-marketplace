---
name: error-envelope-authoring
description: Ensure any new error path emits an envelope with `code`, `message`, and `correlationId`
scope: backend
inherits: plan-and-implement
composes-rules: [error-envelope, typed-error-handling, api-contract-first, structured-logging, no-pii-in-logs]
awaits-adr: ADR-04
when-to-invoke: Adding or modifying an error path / central error handler
sources:
  - shared-ai-brain/decision-log/2026-04-21-adr-04-error-envelope.md
  - fb-rates-go/.cursor/service-knowledge-base/coding-guidelines.md
---
# error-envelope-authoring

## Purpose
Ensure any new error path emits an envelope with `code`, `message`, and `correlationId`. Bakes the interim ADR-04 contract into handler code; ready to sweep when ADR-04 accepts.

## 7 steps

### 1. Understand
Identify the target service and its current envelope shape. Find the central error handler.

### 2. Plan
- Typed error class / struct / exception tied to the service's hierarchy.
- Error code constant in the service's codes file.
- Central handler mapping: typed error → HTTP status → envelope.
- `correlationId` pulled from request context — never generated at emit time.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
Emit code + test that asserts the envelope contains all three fields.

### 6. Self-check
- Envelope has `code`, `message`, `correlationId`.
- Error not logged with raw request body.
- Code constant uniquely named across the service.

### 7. Cleanup
Run the service's test target.

## Related
- Rules: `error-envelope`, `typed-error-handling`.
- Agents: `contract-agent`, `adr-compliance-agent`.
- ADRs: ADR-04.
