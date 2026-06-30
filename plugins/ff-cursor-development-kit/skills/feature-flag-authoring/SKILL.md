---
name: feature-flag-authoring
description: Introduce a feature flag using the interim convention (env var or per-tenant `feature_flags` collection)
scope: workspace
inherits: plan-and-implement
composes-rules: [feature-flag-tooling, layered-architecture, testing-conventions]
awaits-adr: ADR-10
when-to-invoke: Guarding a new user-visible behavior behind a flag
sources:
  - shared-ai-brain/decision-log/2026-04-21-adr-10-feature-flag-tooling.md
---
# feature-flag-authoring

## Purpose
Introduce a feature flag using the interim convention (env var or per-tenant `feature_flags` collection). Carries an ADR-10 pointer so flags migrate cleanly when tooling lands.

## 7 steps

### 1. Understand
Decide rollout shape: global (env var) vs per-tenant (DB-backed on the owning service).

### 2. Plan
- Flag name: `FEATURE_<UPPER_SNAKE>`.
- Default value: `off`.
- Owning ticket + planned removal date.
- Read-site in the service layer (not in controllers or UI directly).
- If per-tenant: storage row and migration script.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
- Add flag definition to the service's flags module.
- Wire service-layer read.
- Add a test that covers both flag-on and flag-off paths.

### 6. Self-check
- Flag default is `off`; enabling in a specific environment is a config change, not a code change.
- Planned removal date present.
- No ad hoc email-suffix / env comparisons dressed up as flags.

### 7. Cleanup
Run the service's test target.

## Related
- Rules: `feature-flag-tooling`, `testing-conventions`.
- Agents: `architecture-agent`, `adr-compliance-agent`.
- ADRs: ADR-10.
