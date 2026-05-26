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
  → review-aggregator step (orchestrator collects all 14 findings, formats them as ONE comment, posts it to the JIRA ticket via `jira-write-permissions`)
  → [HUMAN APPROVAL GATE 2 — only emitted after the consolidated JIRA comment lands]
  → stop (developer raises the MR)
```

Every agent above MUST banner per [`agent-attribution`](../rules/agent-attribution.md) before its output — H3 heading `### ▸ [<N>/11] <agent-name>` on line 1, italic action on line 2. The 14 reviewers share one grouped banner (`### ▸ [8/11] review-agents (×14, parallel)` / `*analysing the committed diff*`); per-reviewer banners are suppressed.

## Review-aggregator step (between reviewers and Gate 2)

The `/implement` orchestrator — not the individual reviewers — performs this step:

1. Wait for all 14 review agents to return their findings (format: `<agent-name>: <findings>` or `<agent-name>: Clear`).
2. Concatenate into a single JIRA comment body:
   ```
   AI Review — <JIRA-KEY> — <feature-branch-name>

   code-review-agent: <findings or "Clear">
   security-agent: <findings or "Clear">
   architecture-agent: <findings or "Clear">
   service-boundary-agent: <findings or "Clear">
   data-ownership-agent: <findings or "Clear">
   tenant-isolation-agent: <findings or "Clear">
   contract-agent: <findings or "Clear">
   test-agent: <findings or "Clear">
   observability-agent: <findings or "Clear">
   migration-agent: <findings or "Clear">
   performance-agent: <findings or "Clear">
   prompt-review-agent: <findings or "Clear">
   adr-compliance-agent: <findings or "Clear">
   async-transport-agent: <findings or "Clear">

   — Posted by /implement before Gate 2.
   ```
3. POST the comment to the JIRA ticket (see [`jira-write-permissions`](../rules/jira-write-permissions.md) — comment-add is allowed; deletes are universally forbidden).
4. Banner `### ▸ [9/11] review-aggregator` / `*posting consolidated findings to JIRA-<KEY>*`, then once posted, banner `### ▸ [10/11] Gate 2` / `*waiting for your approval (review the consolidated JIRA comment first)*`.
5. Emit the Gate 2 prompt verbatim per [`human-approval-gates`](../rules/human-approval-gates.md).

If any reviewer returns a **Blocker**, the orchestrator still posts the consolidated comment (so the developer has a record), but halts before Gate 2 with the heading banner `### ▸ [9/11] review-aggregator` / `*HALT before Gate 2: <N> Blocker finding(s) — see JIRA-<KEY>*`. The developer fixes on the feature branch and re-runs.

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
- All 14 review agents MUST run after `coder-agent` and before Gate 2 — none may be skipped. The orchestrator MUST aggregate their findings into one JIRA comment and post it before emitting the Gate 2 prompt (`human-approval-gates`).
- Review agents return findings to the orchestrator only; they do not call the JIRA API themselves (`jira-write-permissions`).
- Every agent banners per `agent-attribution` so the developer can see which agent is acting at every step.
- If any review agent returns a Blocker finding, the pipeline halts before Gate 2. The commit stays on the feature branch; the developer fixes in place and re-runs.
- **Post-Gate-2 finalize**: when the developer approves Gate 2, the orchestrator MUST (1) call `task-history-writer` with phase `gate-2` to append the final section to `ai-brain/task-history/<KEY>.md`, (2) verify the file exists with `last-phase: gate-2` stamped, (3) emit the completion panel per `pipeline-checklist`. The run does not end until all three are done. See `human-approval-gates` constraints.

## Completion panel (after Gate 2 approve)

The orchestrator emits a single panel to chat in this exact structure:

1. **Phase checklist** — markdown table per `pipeline-checklist`, one row per phase, status `DONE` / `SKIPPED` / `HALTED` / `N/A`. Row `0` is `/implement <KEY> (invoked)`. Last row is `task-history finalized` with the file path in parens.
2. **Summary table** — rows: `Repo`, `Feature branch`, `Base`, `Commit`, `File(s) changed`, `Review result`, `JIRA comment`, `Task history`. The `Task history` row MUST contain the verified file path (`efp-ai-knowledge-base/ai-brain/task-history/<KEY>.md`).
3. **Your next step — raise the MR** block — `cd <repo>` and `git push origin <feature-branch>` per affected repo, plus "open a Merge Request on GitLab from `<feature-branch>` → `<base>`".

If task-history verification fails in step (1) of the finalize sequence, the orchestrator MUST NOT emit "complete" — it emits the halt banner (`### ▸ [11/11] task-history finalize` / `*HALT after Gate 2: finalize failed at ai-brain/task-history/<KEY>.md*`) and stops. This is the only signal that the file is missing.

## Failure handling
Any agent failure halts the pipeline, records the failure in the task-history, and (unless `--no-jira-comment`) posts a JIRA comment summarising what's missing. The pipeline never transitions the ticket — its workflow status is left exactly as the developer set it.

## Resumability
If the developer re-invokes `/implement <KEY>`, the pipeline reads `last-phase` from `task-history/<KEY>.md` frontmatter and resumes from the next phase.

## Related
- Commands: `/bugfix`, `/plan`, `/triage`.
- Rules: `ticket-completeness`, `human-approval-gates`, `base-branch-selection`, `jira-write-permissions`, `agent-attribution`, `pipeline-checklist`.
