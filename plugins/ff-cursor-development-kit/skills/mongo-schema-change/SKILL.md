---
name: mongo-schema-change
description: Evolve a MongoDB schema backward-compatibly
scope: fb-rates-go, fb-iqs, quote-ai-backend, skipperroutes, admin-backend, extraction-service
inherits: plan-and-implement
composes-rules: [migration-safety, tenant-isolation, service-boundary-and-data-ownership, api-contract-first, testing-conventions]
when-to-invoke: Any MongoDB schema change (new field, new index, new collection)
sources:
  - efp-ai-knowledge-base/01-EFP/03-efp-database-model/mongodb-models.md
  - fb-rates-go/.cursor/service-knowledge-base/data-store.md
---
# mongo-schema-change

## Purpose
Evolve a MongoDB schema backward-compatibly. Supports per-tenant fan-out (fb-rates-go / fb-iqs) and shared-DB patterns (admin-backend / quote-ai-backend).

## 7 steps

### 1. Understand
Identify target collection and its owner (from `ownership-matrix.md`). Determine tenancy pattern:
- fb-rates-go per-tenant (apply per vendor in `tenant_connection`).
- fb-iqs per-tenant.
- quote-ai-backend shared with `vendorId` field.
- admin-backend shared (no tenant).
- extraction-service shared.

### 2. Plan
- Field addition: optional with default; writers update before readers require it.
- Field rename: add new, dual-write, migrate readers, deprecate old — across ≥2 releases.
- Index: analyze cost; build in background; document query plan impact.
- Collection add: full schema + validation + initial indexes.

### 3. Propose
Rollout plan + rollback plan + tenant backfill strategy (for per-tenant).

### 4. Pause for human approval

### 5. Implement
- Migration script in the repo's migration folder.
- Per-tenant migrations iterate `tenant_connection` and are resumable (record progress, skip completed).
- Consumer code reads the new field with a default; does not require it.

### 6. Self-check
- Migration is idempotent.
- Rollback path exists and was tested.
- No consumer released in the same release that requires the new field as non-optional.

### 7. Cleanup / regression
Run migration on staging; verify resumability by interrupting and re-running.

## Quality gates
- Per-tenant migrations without resumability are rejected.
- Index additions without query-plan analysis are rejected on large collections.

## Related
- Skills: `mysql-schema-change`, `datastore-kind-change`.
- Agents: `migration-agent`, `data-ownership-agent`, `tenant-isolation-agent`.
