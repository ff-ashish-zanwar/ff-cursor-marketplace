---
name: plan
description: Plan-only
command: /plan
arguments: <JIRA-KEY>
category: primary
on-demand: true
side-effects: writes task-history/<KEY>.md up to the Plan section only; no code changes
---
# /plan <JIRA-KEY>

## Purpose
Plan-only. Stops after the planner-agent emits its output. Useful for scoping reviews, estimation, and sanity-checking the approach before committing to `/implement`.

## Pipeline
```
jira-agent → ticket-completeness-agent → router-agent → planner-agent → stop
```

## Required skills
`jira-ticket-parser`, `building-block-router`, `plan-and-implement`.

## Outputs
- `task-history/<KEY>.md` populated through `## Plan`.
- No Gate 1; no code.
- A **completion checklist** per [`pipeline-checklist`](../rules/pipeline-checklist.md) at termination, listing each phase that ran (`jira-agent`, `ticket-completeness-agent`, `router-agent`, `planner-agent`, `task-history finalized`). Rows for `Gate 1` through `Gate 2` are marked `N/A`.

## Quality gates
- Relaxed `ticket-completeness`: `/plan` may run on a ticket missing acceptance criteria but labels the plan `speculative` and cannot be promoted to `/implement` until criteria are added.

## Related
- Commands: `/implement`, `/triage`, `/db-impact`.
- Agents: `planner-agent`.
