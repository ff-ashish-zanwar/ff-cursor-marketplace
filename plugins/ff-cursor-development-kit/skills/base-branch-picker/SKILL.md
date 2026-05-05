---
name: base-branch-picker
description: For each affected repo, ask the developer which base branch to build on, verify the working tree is clean, and create a fresh feature branch off that base
scope: pipeline-support (runs after Gate 1, before coder-agent)
inherits: plan-and-implement
composes-rules: [base-branch-selection, human-approval-gates, no-invented-facts]
when-to-invoke: Consumed by `base-branch-picker-agent` immediately after Gate 1 approves the plan, before the coder-agent writes any code
sources:
  - efp-ai-knowledge-base/ai-workflow/walkthrough-findings.md
---
# base-branch-picker

## Purpose
For each affected repo, ask the developer which base branch to build on, verify the working tree is clean, and create a fresh feature branch off that base. Leaves the developer on the feature branch so the coder-agent can commit directly onto it. Never pushes, never commits, never opens an MR.

## Inputs
- List of affected repos (from the planner-agent's `## Plan` output).
- Developer on the terminal.

## Outputs
- Per repo: `{ repo, base_branch, feature_branch }`.
- Entry appended to `ai-brain/task-history/<KEY>.md` under `## Base Branches Chosen`.
- Developer's checkout in each affected repo is on `ai/<JIRA-KEY>-<short-slug>`, based on `origin/<chosen-base>`, with a clean working tree.

## 7 steps

### 1. Understand
Read the affected-repos list from the plan. For each repo, detect the default branch from `git remote show origin`:
- If default is `development`, offer `development`.
- Else offer `main` / `master`.
- Offer the detected default as the suggested base.

### 2. Plan
For each repo, construct the feature branch name: `ai/<JIRA-KEY>-<short-slug>`. Short slug comes from the ticket title (lowercase, hyphens, max 40 chars).

### 3. Propose
Emit the per-repo plan (repo → suggested base → feature branch name). Await developer confirmation.

### 4. Pause for human approval
Per-repo confirmation is supported; the developer can override the default base for any repo. This prompt is typically folded into Gate 1's reply so it is one interaction, not two — but the per-repo override remains explicit.

### 5. Implement
For each repo, in order:

1. **Verify clean tree**: `git status --porcelain`. If the output is non-empty, halt with the list of dirty/untracked files and ask the developer to commit, stash, or discard them before re-running. Do NOT stash, do NOT commit, do NOT overwrite.
2. **Fetch** the latest remote state: `git fetch origin`.
3. **Create the feature branch off the chosen base**: `git checkout -b ai/<JIRA-KEY>-<short-slug> origin/<chosen-base>`. The working tree now matches `origin/<chosen-base>` and the developer is on the feature branch.
4. **Stop** — do not commit. The coder-agent will add the code and commit on this branch.

### 6. Self-check
- No `git push`, no `--force`, no `--amend`, no `git commit` anywhere in this skill.
- No `git stash` anywhere — dirty tree is a halt condition, not something to hide.
- If the base branch is protected on the server (e.g., `main`), ask the developer to pick a different base before creating the feature branch.
- The feature branch must be based on `origin/<chosen-base>` (freshly fetched), not on whatever the developer's local `<chosen-base>` happens to point at.

### 7. Cleanup
Leave the developer on the feature branch. Do not switch branches automatically. The pipeline now hands off to the coder-agent, which will commit onto this same branch.

## Quality gates
- Any attempted `git push` / `git commit` / `git stash` within this skill is rejected; the skill stops with an error.
- A dirty working tree is never an acceptable input state — the skill halts and tells the developer to clean up.

## Related
- Agents: `base-branch-picker-agent`.
- Commands: `/implement`, `/bugfix`.
- Rules: `base-branch-selection`.
- Downstream: `coder-agent` commits onto the branch this skill creates.
