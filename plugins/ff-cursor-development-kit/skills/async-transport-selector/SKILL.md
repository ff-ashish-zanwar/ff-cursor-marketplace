---
name: async-transport-selector
description: Decision helper: for a proposed async flow, recommend the transport that aligns with the producer's service family per ADR-02's interim rule
scope: per-service-family (async messaging)
inherits: plan-and-implement
composes-rules: [async-transport-per-service-family, service-boundary-and-data-ownership, no-invented-facts]
awaits-adr: ADR-02
when-to-invoke: Planning a new async flow; invoked by `event-contract-authoring` and `async-transport-agent`
sources:
  - efp-ai-knowledge-base/ai-brain/decision-log/2026-04-21-adr-02-async-messaging.md
  - efp-ai-knowledge-base/ai-brain/building-block-to-services.json
---
# async-transport-selector

## Purpose
Decision helper: for a proposed async flow, recommend the transport that aligns with the producer's service family per ADR-02's interim rule. Stops the developer from casually picking "whichever queue is nearest."

## Inputs
- Producer service.
- Consumer service(s).
- Delivery semantics needed (at-least-once, scheduled, fan-out).

## Outputs
- Recommended transport + justification + `awaits-adr: ADR-02` note.

## Selection matrix (interim)

| Producer family | Delivery | Transport |
|---|---|---|
| fb-rates-go (tariff events) | at-least-once, in-service | Mongo queue |
| quote-ai-backend (pipeline) | at-least-once, ordered-enough | Asynq |
| fb-rates-go → rate-agent / rate-extraction-service | cross-cloud, at-least-once | GCP Datastore TaskQueue |
| rate-agent → qa-agent | cross-kind within GCP | QATaskQueue |
| Any AWS service → notifications | at-least-once, fan-out | AWS SQS |
| fb-iqs (quote reminders) | scheduled, single-fire | AWS EventBridge Scheduler |
| Third-party inbound | webhook push | Gmail / MS Graph webhook into quote-ai-backend |

## 7 steps

### 1. Understand
Resolve the producer family and the call's semantic needs.

### 2. Plan
Look up the matrix; if no row matches, emit `TBD — ADR-02 amendment required`.

### 3. Propose
Emit `{ transport, reason, awaits_adr: "ADR-02" }`.

### 4. Pause
Dev can override but the override is logged into the ADR-02 scaffold as a data point.

### 5. Implement
This is a read-only decision skill — no writes outside the task-history note.

### 6. Self-check
- Matrix consulted, not invented.
- ADR-02 reference attached.

### 7. Cleanup
None.

## Related
- Skills: `event-contract-authoring`.
- Agents: `async-transport-agent`.
- ADRs: ADR-02.
