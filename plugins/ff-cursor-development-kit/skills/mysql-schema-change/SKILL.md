---
name: mysql-schema-change
description: Backward-compatible MySQL migration with an explicit rollout + rollback plan and index impact analysis
scope: admin-backend, fy-iam-go, fb-rates-go (efp_legs), fb-iqs (shipper reference)
inherits: plan-and-implement
composes-rules: [migration-safety, service-boundary-and-data-ownership, testing-conventions]
when-to-invoke: Any MySQL schema change
sources:
  - efp-ai-brain/01-EFP/03-efp-database-model/data-model-overview.md
  - admin-backend/.cursor/service-knowledge-base/data-store.md
  - fy-iam-go/.cursor/service-knowledge-base/data-store.md
---
# mysql-schema-change

## Purpose
Backward-compatible MySQL migration with an explicit rollout + rollback plan and index impact analysis.

## 7 steps

### 1. Understand
Identify target schema + consumers (per `ownership-matrix.md`). Check whether the table is hot (frequent writes) vs cold (reference data).

### 2. Plan
- Additive-first: add nullable column, default, or new table; flip consumers after deploy.
- Rename: use the expand-contract pattern: add → dual-write → switch reads → drop old.
- Hot tables: use online DDL (`ALGORITHM=INPLACE, LOCK=NONE`) or an online schema-change tool. Table-locking DDL requires a maintenance window.
- Index change: EXPLAIN the query before and after; document the row-count impact.

### 3. Propose
Migration file + rollout + rollback + estimated lock time.

### 4. Pause for human approval

### 5. Implement
Migration script using the repo's migration framework. Commit alongside the consuming code (but not code that requires the new shape).

### 6. Self-check
- Migration runs forwards cleanly.
- Rollback script exists and runs cleanly.
- Any FK changes audited against consumer queries.

### 7. Cleanup / regression
Run in staging; verify with `EXPLAIN` on known queries.

## Quality gates
- Dropping a column or index in the same release that stops writing to it is rejected.
- Lock-acquiring migrations on `tenant_connection` or `users` are rejected without maintenance windowing.

## Related
- Skills: `mongo-schema-change`, `datastore-kind-change`.
- Agents: `migration-agent`.
