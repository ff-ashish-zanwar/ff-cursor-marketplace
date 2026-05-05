---
name: review-code
description: Run the `pr-review` skill against an arbitrary diff
command: /review-code
arguments: <branch-or-diff-or-PR-url>
category: review
on-demand: true
side-effects: none (read-only)
---
# /review-code

## Purpose
Run the `pr-review` skill against an arbitrary diff. Not JIRA-tied. Produces a scored (/100) review with severity-grouped findings.

## Inputs
- A source branch, a diff file, or a GitLab MR URL.
- Optional target branch (defaults to the repo's default branch).

## Required skills
`pr-review`.

## Outputs
- Markdown review: score, issues grouped by Blocker / Major / Minor / Nit, each with file:line + rule or standard cited.

## Review scope
The command is diff-focused: it reads changed files + 20 lines of context, never the whole repo.

## Related
- Skills: `pr-review`.
- Agents: `code-review-agent`, `security-agent`, `architecture-agent`, `test-agent`.
