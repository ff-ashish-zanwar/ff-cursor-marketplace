---
name: pr-review
description: Source → target diff review
scope: workspace
inherits: plan-and-implement (skips gates; review-only)
composes-rules: all applicable rules per affected repo
when-to-invoke: `/review-code <branch-or-diff>`; also composed by `code-review-agent`
sources:
  - freightify-web/.cursor/skills/pr-review/SKILL.md
---
# pr-review

## Purpose
Source → target diff review. Scored /100. No full-repo scan, no blanket "looks good" — every finding cites a file:line.

## Inputs
- Source branch / diff / PR URL.
- Target branch (default: repo's default branch).

## Outputs
- Scored review: /100.
- Issues grouped by severity: Blocker, Major, Minor, Nit.
- Each issue cites file:line + the rule or standard it violates.

## Review algorithm

1. **Scope the diff.** Load only changed files + 20 lines of context above/below. No repo-wide scans.
2. **Detect the repo's stack** from `ai-brain/service-cards/<repo>.md` so the applicable rule set is known.
3. **Per changed file**, walk the rule set in order:
   - Workspace-universal rules first.
   - Language-family rules next (Go / TS / Python).
   - Frontend / Angular rules where applicable.
   - AI-service rules where applicable.
   - ADR-scoped rules last.
4. **Score**: start at 100; subtract 20 per Blocker, 10 per Major, 5 per Minor, 2 per Nit. Floor at 0.
5. **Emit** the findings plus the final score.

## Severity definitions
- **Blocker**: tenant-isolation bypass, auth chain broken, secret committed, contract-break without versioning.
- **Major**: rule violation with correctness impact (error handling skipped, service boundary violated, migration not backward-compatible).
- **Minor**: style / pattern deviation (layering bent but contained, missing test case, suboptimal structure).
- **Nit**: formatting, naming.

## Quality gates
- Review never approves a PR with a Blocker.
- Review includes a concrete remediation suggestion for each Major+ finding.

## Related
- Agents: `code-review-agent`, `security-agent`, `architecture-agent`, `test-agent`.
- Commands: `/review-code`.
