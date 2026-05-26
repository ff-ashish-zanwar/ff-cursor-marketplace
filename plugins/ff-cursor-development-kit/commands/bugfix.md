---
name: bugfix
description: Bug-specialized variant of `/implement`
command: /bugfix
arguments: <JIRA-KEY>
category: primary
on-demand: true
side-effects: same as /implement
---
# /bugfix <JIRA-KEY>

## Purpose
Bug-specialized variant of `/implement`. Forces RCA (root-cause analysis) before any fix is proposed.

## Inputs
- JIRA ticket key (bug type, **must include reproduction steps**). Any JIRA workflow status is accepted; the ticket's status is captured into the intake but does not gate the pipeline.

## Pipeline
Identical to `/implement` with one insertion (rca-agent between router-agent and planner-agent):
```
...router-agent → rca-agent → planner-agent → [GATE 1 — plan + base branches] → base-branch-picker-agent → coder-agent → 14 review agents (parallel) → review-aggregator (posts consolidated comment to JIRA) → [GATE 2] → stop
```
`rca-agent` uses the `bug-fix` skill. It produces a reproduction confirmation, evidence, and a root-cause note before anything is planned.

The review-aggregator step and Gate 2 ordering are identical to `/implement` — see [`commands/implement.md`](implement.md) "Review-aggregator step" and rules [`human-approval-gates`](../rules/human-approval-gates.md), [`jira-write-permissions`](../rules/jira-write-permissions.md), [`agent-attribution`](../rules/agent-attribution.md).

## Required skills
All `/implement` skills plus `bug-fix`.

## Outputs
Same as `/implement`, plus an `## RCA` section in the task-history file between `## Routing` and `## Plan`.

## Quality gates
- Reproduction steps are mandatory; `ticket-completeness-agent` rejects bug tickets lacking them.
- Fix without regression test is rejected by `test-agent`.
- Fixing the symptom without the root cause is rejected at Gate 1.

## Related
- Commands: `/implement`, `/plan`, `/triage`.
- Agents: `rca-agent`, `test-agent`.
- Skills: `bug-fix`.
