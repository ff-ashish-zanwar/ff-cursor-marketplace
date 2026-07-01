---
name: ticket-authoring
description: Author a complete, `/implement`-ready JIRA ticket **tree** (one parent + the user-listed sub-tasks) from a free-text idea, grounded in the AI-brains
scope: pipeline-support (product)
inherits: plan-and-implement
composes-rules: [no-invented-facts, ticket-completeness, implement-intake-format, human-approval-gates, jira-write-permissions, no-pii-in-logs]
when-to-invoke: Consumed by `/author-ticket` across `product-intake-agent`, `ticket-composer-agent`, `jira-writer-agent`
sources:
  - shared-ai-brain/consumer-registry.json
  - <product>-ai-brain/routing.json
  - <product>-ai-brain/index/<repo>.md
---
# ticket-authoring

## Purpose
Author a complete, `/implement`-ready JIRA ticket **tree** (one parent + the user-listed sub-tasks) from a free-text idea, grounded in the AI-brains. The developer-lane counterpart of `plan-and-implement`. Every drafted field is either brain-grounded (cited) or marked `TBD — <question>`; sub-tasks are user-listed and AI-enriched, never invented.

## Inputs
- Confirmed idea **+ the user's sub-task list** (from `product-intake-agent`).
- Routing result **per node** (building block → product → repos + blast radius, from `router-agent` over `routing.json` + `consumer-registry.json`).
- Project/board/component resolved from `jira-projects.json`, plus **createmeta** (fields/required/allowed) for the resolved project + issue type(s).
- Epic hint (`--epic` / inline / none) and type hint (`--type` / `--bug` / none — else AI-classified).

## Outputs
A ticket **tree** draft (parent + enriched sub-tasks) in [`implement-intake-format`](../rules/implement-intake-format.md), written into the task-history `## Authoring` section, ready for `ticket-completeness` (every sub-task leaf-ready) and Gate-P.

## 7 steps
### 1. Understand
Read the confirmed idea + the user's sub-task list + the routed repos' brain `index/` cards (per node). Resolve acronyms via `dictionaries/lookups.json`.

### 2. Plan
Map idea → building block → repos → project/board/component for the parent AND each sub-task. Read createmeta (fields/required/allowed) for the resolved project + issue type(s). Classify the parent type (Story/Task/Bug). Identify blast radius (shared-service consumers) per node so the tree flags cross-product impact.

### 3. Propose / draft
Compose the parent (title, problem/user story, AC ≥1 cited, repro if Bug) and **enrich each user-listed sub-task** (route + problem + AC + repro-if-bug) in `implement-intake-format`. Resolve an existing epic to link (or build a shortlist) — never auto-pick. Unknowns → `TBD — <question>`; never invent a field or a sub-task. (`suggest` mode: propose a per-repo breakdown for the user to accept/edit.)

### 4. Pause for human approval (Gate-P)
User reviews the WHOLE tree (add/remove/split/merge/edit sub-tasks), confirms type + epic, sets required + optional fields → `approve | revise | reject`. Overrides captured in `## Corrections`.

### 5. Implement
On `approve` + create mode: `jira-writer-agent` creates the **parent first**, then each approved sub-task (`parent=<KEY>`), links/creates the epic, and renames the record to `<PARENT-KEY>.md`. Copy-paste mode: emit the formatted tree, no JIRA write.

### 6. Self-check
- Tree conforms to `implement-intake-format`; every sub-task passes `ticket-completeness` (leaf-ready); parent has problem + AC.
- Every createmeta-required field is satisfied (default or Gate-P value).
- No PII/secrets; no invented acceptance criteria or sub-tasks.
- Project auto-resolved + overridable; board explicitly chosen; epic never auto-picked.

### 7. Cleanup
Stamp `last-phase`, `subtask-keys`, `epic`; the `<PARENT-KEY>.md` is now the shared lifecycle record `/implement` will append to (from a leaf).

## Related
- Agents: `product-intake-agent`, `ticket-composer-agent`, `jira-writer-agent`, `router-agent`, `ticket-completeness-agent`.
- Commands: `/author-ticket` → `/implement`.
