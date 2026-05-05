---
name: db-impact
description: Produce a data-model impact analysis across EFP's storage technologies (MongoDB, MySQL, GCP Datastore, DynamoDB, Redis, S3, GCS, OpenSearch)
command: /db-impact
arguments: <JIRA-KEY>
category: brain-maintenance
on-demand: true
side-effects: appends a `## DB Impact` section to task-history/<KEY>.md if present
---
# /db-impact <JIRA-KEY>

## Purpose
Produce a data-model impact analysis across EFP's storage technologies (MongoDB, MySQL, GCP Datastore, DynamoDB, Redis, S3, GCS, OpenSearch). Runs ahead of migration-heavy work so the developer sees the full surface before planning.

## Inputs
- JIRA key. Ticket is fetched via `jira-agent` and routed via `router-agent`.

## Required skills
`jira-ticket-parser`, `building-block-router`.

## Outputs
Per-store analysis:
- Collections / tables / kinds / indexes affected.
- Owning services.
- Tenancy pattern (per-tenant fan-out vs shared).
- Migration skill to use (`mongo-schema-change` / `mysql-schema-change` / `datastore-kind-change`).
- Estimated rollout risk.
- `awaits-adr` references where ADR-03 (tenant isolation) or ADR-04 (envelope) shapes the impact.

## Related
- Commands: `/plan`, `/implement`.
- Skills: `mongo-schema-change`, `mysql-schema-change`, `datastore-kind-change`.
- Agents: `migration-agent`, `data-ownership-agent`.
