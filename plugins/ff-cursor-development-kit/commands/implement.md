---
name: implement
description: Primary entry point
command: /implement
arguments: <JIRA-KEY>
category: primary
on-demand: true
side-effects: writes task-history/<KEY>.md; creates feature branches on affected repos; leaves uncommitted changes on those branches (never stages, never commits, never pushes); optionally pushes the task-history file to `freightify-ai-brain/task-history` and attaches it to the JIRA ticket at Step 13 (opt-in per run)
---
# /implement <JIRA-KEY>

## Purpose
Primary entry point. Runs the full pipeline up to **uncommitted** changes on developer-chosen base branches. The developer reviews, stages, commits, and pushes themselves. After Gate 2 the pipeline offers to publish the task-history file (Step 13) — opt-in.

## Inputs
- JIRA ticket key. Any workflow status is accepted (`To Do`, `In Progress`, `In Review`, `Done`, etc.) — the ticket's status is captured into the task-history intake but does not gate the pipeline.
- Developer-local `JIRA_API_TOKEN`, `JIRA_EMAIL`, `JIRA_BASE_URL`.
- **`freightify-ai-brain` cloned in the developer's workspace** alongside the service repos. `jira-agent` halts at start if the folder is missing — there is no fallback location for the task-history file.

## Pipeline
```
jira-agent
  → ticket-completeness-agent
  → router-agent
  → planner-agent
  → [HUMAN APPROVAL GATE 1 — approve plan + pick base branch per affected repo]
  → base-branch-picker-agent (verify clean tree; fetch; `git checkout -b ai/<KEY>-<slug> origin/<base>` per repo)
  → coder-agent (on the feature branch: edit, test — NO `git add`, NO `git commit`; leaves changes uncommitted on the working tree)
  → [REVIEW-READINESS GATE — developer reviews/edits the uncommitted changes, then approves to start reviews]
  → (code-review + security + architecture + service-boundary + data-ownership + tenant-isolation + contract + test + observability + migration + performance + prompt-review + adr-compliance + async-transport agents in parallel — on the uncommitted working-tree diff)
  → review-aggregator step (orchestrator collects all 14 findings, formats them as ONE comment, posts it to the JIRA ticket via `jira-write-permissions`)
  → [HUMAN APPROVAL GATE 2 — only emitted after the consolidated JIRA comment lands]
  → [STEP 13 — publish task-history? yes / no / later  +  attach to JIRA? yes / no]
  → stop (code changes stay uncommitted; developer stages, commits, pushes, then raises the MR)
```

Every agent above MUST banner per [`agent-attribution`](../rules/agent-attribution.md) before its output — H3 heading `### ▸ [<N>/13] <agent-name>` on line 1, italic action on line 2. The Review-Readiness Gate is `### ▸ [8/13] Review-Readiness Gate`. The 14 reviewers share one grouped banner (`### ▸ [9/13] review-agents (×14, parallel)` / `*analysing the uncommitted working-tree diff*`); per-reviewer banners are suppressed. The Step 13 prompt banners `### ▸ [13/13] publish-history` / `*pushing task-history to freightify-ai-brain/task-history and (optionally) attaching to JIRA*` when the developer answers `yes`; on `no` the banner reads `*skipped — task-history stays local*`; on `later` it reads `*deferred — run /publish-history <KEY> to finish*`.

## Position banner (after every hand-off and every revise)

The orchestrator prints a position banner after every agent hand-off and every `revise` reply at any gate. The banner reads from task-history frontmatter — never from the chat — so the displayed step number is always the next agent that will run.

```
EFP-<KEY> — Step <N> of 13: <phase name> (revision <revise-count>)
Next step on approve: Step <N+1> — <next phase>
Reply: approve | revise <notes> | reject
```

`revise` increments `revise-count` and re-runs the current step; it does NOT advance `current-step`. `approve` always advances. After 5 revises on the same step, the banner appends one extra line — `Heads-up: 5 revisions on this step — want to step back to <previous-step> instead?` — as a soft prompt, not a block.

## Review-Readiness Gate (between coder-agent and the reviewers)

When `coder-agent` finishes, the changes sit on each feature branch's working tree — **uncommitted and unstaged**. The orchestrator does NOT fan out to the review agents yet. Instead it:

1. Banners `### ▸ [8/13] Review-Readiness Gate` / `*coding done — review/edit the uncommitted changes, then approve to start reviews*`.
2. Emits the fixed Review-Readiness Gate prompt per [`human-approval-gates`](../rules/human-approval-gates.md):
   > Coding is complete on `<feature-branch>` — the changes are on your working tree, **uncommitted and unstaged**. Review them and make any edits you want. When you're ready, reply `approve` to start the 14 review agents / `revise <notes>` (coder-agent re-runs) / `reject`.
3. Waits for the developer. `approve` → run the 14 review agents against the current working-tree diff. `revise <notes>` → re-enter `coder-agent` with the notes (banner `[7/13]` again). `reject` → halt and finalize task-history.

The developer's own manual edits made at this gate are part of the working tree, so the reviewers see exactly what the developer intends to ship.

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
4. Banner `### ▸ [10/13] review-aggregator` / `*posting consolidated findings to JIRA-<KEY>*`, then once posted, banner `### ▸ [11/13] Gate 2` / `*waiting for your approval (review the consolidated JIRA comment first)*`.
5. Emit the Gate 2 prompt verbatim per [`human-approval-gates`](../rules/human-approval-gates.md).

If any reviewer returns a **Blocker**, the orchestrator still posts the consolidated comment (so the developer has a record), but halts before Gate 2 with the heading banner `### ▸ [10/13] review-aggregator` / `*HALT before Gate 2: <N> Blocker finding(s) — see JIRA-<KEY>*`. The developer fixes the uncommitted working tree on the feature branch and re-runs.

## Step 13 — publish task-history (after Gate 2 approve)

After the developer approves Gate 2, the orchestrator emits **one** prompt with two questions:

> Task history for `<JIRA-KEY>` is ready at `freightify-ai-brain/ai-brain/task-history/<KEY>.md`.
> Publish it to `freightify-ai-brain` on `task-history`? [`yes` / `no` / `later`]
> Also attach the file to the JIRA ticket? [`yes` / `no`]

Behaviour by reply:

- `publish = yes` → ensure `freightify-ai-brain` working tree is clean; `git checkout task-history`; `git pull --ff-only`; `git add freightify-ai-brain/ai-brain/task-history/<KEY>.md`; `git commit -m "task-history: <KEY> — <ticket title>"`; `git push origin task-history`. Record the resulting commit SHA in frontmatter `published.freightify-ai-brain-commit`.
- `publish = no` → the file stays in the developer's local copy of `freightify-ai-brain`. Frontmatter `last-phase` becomes `publish-history`.
- `publish = later` → frontmatter `last-phase` becomes `publish-pending`. `/publish-history <KEY>` finishes the job at any time.
- `attach-to-jira = yes` → upload the task-history file to the JIRA ticket as an attachment; post a short comment linking to it (allowed by `jira-write-permissions`). Record `published.jira-attachment-id`.
- `attach-to-jira = no` → no JIRA write.

Step 13 is a prompt, not a gate — `no` and `later` are valid answers that still complete the run. The pipeline never falls back to a temp folder; if `freightify-ai-brain` cannot be written on `yes`, Step 13 halts with the path it tried.

## Required skills
`jira-ticket-parser`, `building-block-router`, `plan-and-implement`, `go-gin-api-authoring` / `node-ts-express-authoring` / `python-fastapi-authoring` (as needed), `mongo-schema-change` / `mysql-schema-change` / `datastore-kind-change` (as needed), `event-contract-authoring`, `proxy-integration`, `base-branch-picker`, `task-history-writer`.

## Outputs
- Updated `freightify-ai-brain/ai-brain/task-history/<JIRA-KEY>.md`. One file per JIRA key, forever — re-opens append a `## Run N` section, never a second file.
- Per-repo feature branches created off developer-chosen base branches, carrying **uncommitted, unstaged** changes on the working tree. No commits are made by the pipeline.
- Optional JIRA comment on failure (suppressible with `--no-jira-comment`).
- Step 13 outputs (only when developer answers `yes`): one commit on `freightify-ai-brain/task-history` containing the task-history file; optional JIRA attachment + summary comment.

## Quality gates
- Ticket must satisfy `ticket-completeness`.
- Affected repos must have a clean working tree at `base-branch-picker-agent` time; dirty tree halts the pipeline (the agent never stashes).
- All **three** human approval gates are non-skippable (`human-approval-gates`); Gate 1 also carries the per-repo base-branch choices. The Review-Readiness Gate sits between `coder-agent` and the reviewers.
- The pipeline **never stages, commits, or pushes**. `base-branch-picker-agent` only creates branches; `coder-agent` only edits the working tree (`base-branch-selection`). The developer stages, commits, and pushes themselves after Gate 2.
- No review agent may run until the developer approves the Review-Readiness Gate. All 14 review agents MUST then run before Gate 2 — none may be skipped. They review the **uncommitted working-tree diff** (`git diff origin/<base>`). The orchestrator MUST aggregate their findings into one JIRA comment and post it before emitting the Gate 2 prompt (`human-approval-gates`).
- Review agents return findings to the orchestrator only; they do not call the JIRA API themselves (`jira-write-permissions`).
- Every agent banners per `agent-attribution` so the developer can see which agent is acting at every step.
- If any review agent returns a Blocker finding, the pipeline halts before Gate 2. The uncommitted changes stay on the feature branch's working tree; the developer fixes in place and re-runs.
- **Post-Gate-2 finalize**: when the developer approves Gate 2, the orchestrator MUST (1) call `task-history-writer` with phase `gate-2` to append the final section to `freightify-ai-brain/ai-brain/task-history/<KEY>.md`, (2) verify the file exists with `last-phase: gate-2` stamped, (3) emit the Step 13 prompt (publish-history), (4) handle the developer's reply per the Step 13 section above and re-stamp `last-phase` to `publish-history` / `publish-pending`, (5) emit the completion panel per `pipeline-checklist`. The run does not end until all five are done. The code changes remain uncommitted — the panel tells the developer to stage, commit, and push. See `human-approval-gates` constraints.

## Completion panel (after Gate 2 approve)

The orchestrator emits a single panel to chat in this exact structure:

1. **Phase checklist** — markdown table per `pipeline-checklist`, one row per phase, status `DONE` / `SKIPPED` / `HALTED` / `N/A`. Row `0` is `/implement <KEY> (invoked)`. Row `12` is `task-history finalized` with the file path in parens. Row `13` is `publish-history` with status `DONE (commit <sha>)` / `SKIPPED (no)` / `DEFERRED (later)` / `HALTED (<reason>)`.
2. **Summary table** — rows: `Repo`, `Feature branch`, `Base`, `Working tree` (always `uncommitted`), `File(s) changed`, `Review result`, `JIRA comment`, `Task history`, `Publish` (Step 13 outcome). The `Task history` row MUST contain the verified file path (`freightify-ai-brain/ai-brain/task-history/<KEY>.md`).
3. **Your next step — stage, commit, push, then raise the MR** block — per affected repo: `cd <repo>`, `git add <file(s) changed>`, `git commit`, `git push origin <feature-branch>`, plus "open a Merge Request on GitLab from `<feature-branch>` → `<base>`". The AI never did any of these — staging/commit/push are the developer's.

If task-history verification fails in step (1) of the finalize sequence, the orchestrator MUST NOT emit "complete" — it emits the halt banner (`### ▸ [12/13] task-history finalize` / `*HALT after Gate 2: finalize failed at freightify-ai-brain/ai-brain/task-history/<KEY>.md*`) and stops. This is the only signal that the file is missing.

## Failure handling
Any agent failure halts the pipeline, records the failure in the task-history, and (unless `--no-jira-comment`) posts a JIRA comment summarising what's missing. The pipeline never transitions the ticket — its workflow status is left exactly as the developer set it.

## Resumability
If the developer re-invokes `/implement <KEY>`, the pipeline reads `last-phase` from `task-history/<KEY>.md` frontmatter and resumes from the next phase. There is exactly one task-history file per JIRA key, forever — completed re-opens append a new `## Run N` section to the same file (frontmatter `run-count` increments); `--restart` does the same explicitly. The pipeline never creates a second file for the same key.

## Related
- Commands: `/bugfix`, `/plan`, `/triage`.
- Rules: `ticket-completeness`, `human-approval-gates`, `base-branch-selection`, `jira-write-permissions`, `agent-attribution`, `pipeline-checklist`.
