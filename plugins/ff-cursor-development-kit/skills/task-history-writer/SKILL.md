---
name: task-history-writer
description: Append-only writer for `freightify-ai-brain/ai-brain/task-history/<JIRA-KEY>.md`
scope: pipeline-support
inherits: plan-and-implement
composes-rules: [no-invented-facts, no-pii-in-logs]
when-to-invoke: Every phase transition in the `/implement`, `/bugfix`, `/plan` pipelines
sources:
  - freightify-ai-brain/ai-brain/task-history/_template.md
---
# task-history-writer

## Purpose
Append-only writer for `freightify-ai-brain/ai-brain/task-history/<JIRA-KEY>.md`. Enforces the schema in `_template.md` and keeps the frontmatter in sync.

## Inputs
- JIRA key.
- Phase name (`jira-intake` | `completeness` | `routing` | `rca` | `plan` | `gate-1` | `base-branch-picked` | `code` | `review-ready` | `review` | `review-aggregated` | `gate-2` | `halted`).
- Phase payload (intake, routing, plan, base-branch choices, code artifacts, review result, etc.).

## Outputs
- The task-history file, created if absent (from `_template.md`) and appended to.
- Frontmatter updated: `status`, `last-phase`, `branches`.

## 7 steps

### 1. Understand
Read the existing file if present. Reject a call if the phase ordering is wrong (e.g., `code` arriving before `base-branch-picked`, `review` arriving before `review-ready`, or `gate-2` arriving before `review`).

### 2. Plan
- Append-only section write.
- Frontmatter updates via a YAML load → patch → dump flow; do not rewrite the body.

### 3. Propose
Skill is internal; no developer approval needed.

### 4. Pause
(skipped for this internal skill)

### 5. Implement
- Frontmatter: update `last-phase`. For `base-branch-picked`, append `{repo, base, feature}` entries to `branches` with empty `commit_sha`. `commit_sha` stays empty for the whole pipeline — the pipeline never commits, so no phase back-fills it. The `review-ready` phase records the Review-Readiness Gate approval; `code` records files touched/tests added and that the tree is left uncommitted.
- Body: append a `## <Phase>` section if the section does not exist yet; if it already exists, sub-append a timestamped subsection; never rewrite.

### 6. Self-check
- Idempotent: re-running the same call does not duplicate sections.
- No PII / secrets in appended content.
- Phase ordering valid.

### 7. Cleanup
None.

## Related
- Agents: every agent calls this skill at its completion.
