---
name: bugfix
description: Bug-specialized variant of `/implement`
command: /bugfix
arguments: <JIRA-KEY>
category: primary
on-demand: true
side-effects: same as /implement (leaves uncommitted changes; never stages, commits, or pushes)
---
# /bugfix <JIRA-KEY>

## Purpose
Bug-specialized variant of `/implement`. Forces RCA (root-cause analysis) before any fix is proposed.

## Inputs
- JIRA ticket key (bug type, **must include reproduction steps**). Any JIRA workflow status is accepted; the ticket's status is captured into the intake but does not gate the pipeline.

## Pipeline
Identical to `/implement` with one insertion (rca-agent between router-agent and planner-agent):
```
...router-agent → rca-agent → planner-agent → [GATE 1 — plan + base branches] → base-branch-picker-agent → coder-agent (no commit) → [REVIEW-READINESS GATE] → 14 review agents (parallel, on the uncommitted diff) → review-aggregator (posts consolidated comment to JIRA) → [GATE 2] → [STEP 13 — publish task-history? yes / no / later  +  attach to JIRA? yes / no] → stop (code changes uncommitted; developer commits)
```
`rca-agent` uses the `bug-fix` skill. It produces a reproduction confirmation, evidence, and a root-cause note before anything is planned.

Total phase count is **14** for `/bugfix` (one more than `/implement` because of `rca-agent`). All agent banners use `[<N>/14]` instead of `[<N>/13]`. The Review-Readiness Gate is `### ▸ [9/14] Review-Readiness Gate`; review-agents is `### ▸ [10/14]`; review-aggregator `[11/14]`; Gate 2 `[12/14]`; task-history finalize `[13/14]`; publish-history `[14/14]`.

The review-aggregator step and Gate 2 ordering are identical to `/implement` — see [`commands/implement.md`](implement.md) "Review-aggregator step" and rules [`human-approval-gates`](../rules/human-approval-gates.md), [`jira-write-permissions`](../rules/jira-write-permissions.md), [`agent-attribution`](../rules/agent-attribution.md).

## Required skills
All `/implement` skills plus `bug-fix`.

## Outputs
Same as `/implement`, plus an `## RCA` section in the task-history file between `## Routing` and `## Plan`.

## Quality gates
- Reproduction steps are mandatory; `ticket-completeness-agent` rejects bug tickets lacking them.
- Fix without regression test is rejected by `test-agent`.
- Fixing the symptom without the root cause is rejected at Gate 1.

The post-Gate-2 finalize, Step 13 (publish-history) prompt, completion panel, position banner, and revise-loop discipline are identical to `/implement` — see [`commands/implement.md`](implement.md) "Step 13", "Completion panel", and "Position banner". For `/bugfix`, the checklist row for `rca-agent` is `DONE` (it's `N/A` on `/implement`), and the total row count is 14 instead of 13.

## Related
- Commands: `/implement`, `/plan`, `/triage`.
- Agents: `rca-agent`, `test-agent`.
- Skills: `bug-fix`, `task-history-writer`.
- Rules: `pipeline-checklist`, `human-approval-gates`, `jira-write-permissions`, `agent-attribution`.
