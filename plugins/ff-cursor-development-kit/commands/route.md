---
name: route
description: Resolve a text description or JIRA key to building-block / module / sub-module / owning services via `router-agent`
command: /route
arguments: <free-text-or-JIRA-KEY>
category: brain-maintenance
on-demand: true
side-effects: none (read-only); optionally appends routing to task-history/<KEY>.md if a JIRA key is given
---
# /route

## Purpose
Resolve a text description or JIRA key to building-block / module / sub-module / owning services via `router-agent`. No downstream agents run.

## Inputs
- Either a JIRA key (fetched via `jira-agent`) or free-text ("add FRLC category to export").

## Required skills
`jira-ticket-parser` (if JIRA key), `building-block-router`.

## Outputs
- JSON-shaped routing:
```json
{ "building_blocks": [...], "modules": [...], "owning_services": [...], "owning_data_stores": [...], "awaits_adrs": [...] }
```
- Plus human-readable narrative.

## When to invoke
- Quick check on who owns a concept before filing a ticket.
- Validating an acronym's home before editing the knowledge base.

## Related
- Commands: `/triage`, `/plan`.
- Agents: `router-agent`.
