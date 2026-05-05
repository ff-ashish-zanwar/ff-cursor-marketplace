---
name: event-contract-authoring
description: Author an async event contract: topic / queue name, payload schema, versioning, idempotency key, dead-letter policy
scope: workspace (any async flow)
inherits: plan-and-implement
composes-rules: [api-contract-first, async-transport-per-service-family, service-boundary-and-data-ownership, structured-logging, no-pii-in-logs, typed-error-handling]
when-to-invoke: Publishing or consuming a new async event / queue message
sources:
  - efp-ai-knowledge-base/01-EFP/04-efp-system-architecture/communication-patterns.md
  - efp-ai-knowledge-base/ai-brain/cross-service-map.md
  - fb-rates-go/.cursor/architecture.md
  - quote-ai-backend/.cursor/architecture.md
---
# event-contract-authoring

## Purpose
Author an async event contract: topic / queue name, payload schema, versioning, idempotency key, dead-letter policy. Transport-agnostic; the transport is selected by `async-transport-per-service-family` (awaits ADR-02).

## 7 steps

### 1. Understand
Identify producer + consumer services. Confirm transport per `async-transport-per-service-family`:
- fb-rates-go tariff events → Mongo queues.
- quote-ai-backend → Asynq.
- Automation pipeline → Datastore TaskQueue / QATaskQueue.
- Cross-service notifications → SQS.
- Scheduled → EventBridge.

### 2. Plan
- Topic / queue name: `<service>.<aggregate>.<verb>.v<N>` (e.g., `fb-rates-go.tariff.published.v1`).
- Payload schema: typed struct (Go) / Pydantic model (Python) / AJV schema (TS).
- Idempotency key: a field in the payload that consumers dedupe on.
- Versioning: bump `vN` on breaking change; support both versions for a release.
- Dead-letter: TTL + max retries + failure destination documented.

### 3. Propose
Contract + producer/consumer plan + rollout.

### 4. Pause for human approval

### 5. Implement
Producer writes the typed payload; consumer deserializes into the same typed model. Idempotency check happens at the start of the consumer.

### 6. Self-check
- Payload never contains raw rate data / tokens / PII (`no-pii-in-logs`).
- `correlationId` propagated in the payload (transport headers are not reliable across clouds).
- Dead-letter policy documented in the service's `service-communication.md`.

### 7. Cleanup / regression
Produce a test event on staging; verify consumer processes it; verify dead-letter triggers on synthetic failure.

## Related
- Skills: `proxy-integration`, `mongo-schema-change` (for Mongo-queue collections), `datastore-kind-change`.
- Agents: `contract-agent`, `async-transport-agent`, `service-boundary-agent`, `observability-agent`.
