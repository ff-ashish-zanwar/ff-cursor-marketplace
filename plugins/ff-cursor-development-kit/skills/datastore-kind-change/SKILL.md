---
name: datastore-kind-change
description: Evolve a Datastore kind or its indexes without stranding in-flight Cloud Run Jobs
scope: extraction-service, rate-agent, qa-agent, rate-extraction-service
inherits: plan-and-implement
composes-rules: [migration-safety, service-boundary-and-data-ownership, testing-conventions]
when-to-invoke: Adding or evolving a GCP Datastore kind (Task, Agent, AgentStep, TaskQueue, QATaskQueue, Recipe)
sources:
  - rate-agent/.cursor/service-knowledge-base/data-store.md
  - qa-agent/.cursor/service-knowledge-base/data-store.md
  - rate-extraction-service/.cursor/service-knowledge-base/data-store.md
---
# datastore-kind-change

## Purpose
Evolve a Datastore kind or its indexes without stranding in-flight Cloud Run Jobs.

## 7 steps

### 1. Understand
Identify the kind and its writers / readers across rate-agent / qa-agent / rate-extraction-service / extraction-service. In-flight jobs may be running against the previous shape.

### 2. Plan
- Additive property: safe; new writers populate, old readers ignore.
- Indexed query change: update `index.yaml`; wait for index build; then deploy consumer.
- Removal: ship a version that stops writing and tolerates absence, then after drainage run a cleanup migration.

### 3. Propose
Rollout order: `index.yaml` first, then writers, then readers. Rollback plan: revert `index.yaml` if needed and re-deploy prior consumer.

### 4. Pause for human approval

### 5. Implement
- Update `index.yaml`; deploy through `gcloud datastore indexes create`.
- Update Pydantic / Go struct models.
- Update writers and readers.

### 6. Self-check
- No in-flight job shape is broken (version-tolerant reader on both sides of the deploy window).
- Index build time accounted for in rollout.

### 7. Cleanup / regression
Staging deploy; manually enqueue a test task and verify the full Cloud Run Job completes.

## Quality gates
- Removing a required property without a tolerance shim is rejected.

## Related
- Skills: `mongo-schema-change`, `mysql-schema-change`, `event-contract-authoring`.
- Agents: `migration-agent`.
