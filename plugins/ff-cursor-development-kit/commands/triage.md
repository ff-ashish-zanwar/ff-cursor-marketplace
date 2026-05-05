---
name: triage
description: Pre-flight check
command: /triage
arguments: <JIRA-KEY>
category: primary
on-demand: true
side-effects: writes task-history/<KEY>.md intake + routing only
---
# /triage <JIRA-KEY>

## Purpose
Pre-flight check. Runs `ticket-completeness-agent` + `router-agent` only. Answers "is this ticket ready to implement and who owns it?"

## Pipeline
```
jira-agent → ticket-completeness-agent → router-agent → stop
```

## Required skills
`jira-ticket-parser`, `building-block-router`.

## Outputs
- `task-history/<KEY>.md` populated with `## Intake` + `## Routing` + `## Completeness`.

## Typical uses
- Incoming ticket review: decide whether to pick it up.
- Workload routing: confirm which building block / services / owner family the work lands on.
- Verifying acceptance criteria before committing to `/implement`.

## Related
- Commands: `/plan`, `/implement`, `/route`.
- Agents: `jira-agent`, `ticket-completeness-agent`, `router-agent`.
