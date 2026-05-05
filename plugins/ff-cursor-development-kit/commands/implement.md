---
name: implement
description: Primary entry point
command: /implement
arguments: <JIRA-KEY>
category: primary
on-demand: true
side-effects: writes task-history/<KEY>.md; creates feature branches on affected repos; commits locally (never pushes)
---
# /implement <JIRA-KEY>

## Purpose
Primary entry point. Runs the full pipeline up to commits on developer-chosen base branches.

## Inputs
- JIRA ticket key. Any workflow status is accepted (`To Do`, `In Progress`, `In Review`, `Done`, etc.) — the ticket's status is captured into the task-history intake but does not gate the pipeline.
- Developer-local `JIRA_API_TOKEN`, `JIRA_EMAIL`, `JIRA_BASE_URL`.

## Pipeline
```
jira-agent
  → ticket-completeness-agent
  → router-agent
  → planner-agent
  → [HUMAN APPROVAL GATE 1 — approve plan + pick base branch per affected repo]
  → base-branch-picker-agent (verify clean tree; fetch; `git checkout -b ai/<KEY>-<slug> origin/<base>` per repo)
  → coder-agent (on the feature branch: edit, test, `git add`, `git commit`)
  → (code-review + security + architecture + service-boundary + data-ownership + tenant-isolation + contract + test + observability + migration + performance + prompt-review + adr-compliance + async-transport agents in parallel)
  → [HUMAN APPROVAL GATE 2]
  → stop (developer raises the MR)
```

## Required skills
`jira-ticket-parser`, `building-block-router`, `plan-and-implement`, `go-gin-api-authoring` / `node-ts-express-authoring` / `python-fastapi-authoring` (as needed), `mongo-schema-change` / `mysql-schema-change` / `datastore-kind-change` (as needed), `event-contract-authoring`, `proxy-integration`, `base-branch-picker`, `task-history-writer`.

## Outputs
- Updated `ai-brain/task-history/<JIRA-KEY>.md`.
- Per-repo feature branches with commits, created off developer-chosen base branches.
- Optional JIRA comment on failure (suppressible with `--no-jira-comment`).

## Quality gates
- Ticket must satisfy `ticket-completeness`.
- Affected repos must have a clean working tree at `base-branch-picker-agent` time; dirty tree halts the pipeline (the agent never stashes).
- Both human approval gates are non-skippable (`human-approval-gates`); Gate 1 also carries the per-repo base-branch choices.
- `base-branch-picker-agent` never pushes, never commits, never opens a merge request (`base-branch-selection`). Commits are made by `coder-agent` onto the feature branch the picker creates.
- If any review agent returns a Blocker finding, the pipeline halts before Gate 2. The commit stays on the feature branch; the developer fixes in place and re-runs.

## Failure handling
Any agent failure halts the pipeline, records the failure in the task-history, and (unless `--no-jira-comment`) posts a JIRA comment summarising what's missing. The pipeline never transitions the ticket — its workflow status is left exactly as the developer set it.

## Resumability
If the developer re-invokes `/implement <KEY>`, the pipeline reads `last-phase` from `task-history/<KEY>.md` frontmatter and resumes from the next phase.

## Related
- Commands: `/bugfix`, `/plan`, `/triage`.
- Rules: `ticket-completeness`, `human-approval-gates`, `base-branch-selection`.
