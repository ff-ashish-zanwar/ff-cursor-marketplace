---
name: review-ui
description: Screen-level UI review
command: /review-ui
arguments: <screen-or-route-or-component-path>
category: review
on-demand: true
side-effects: none (read-only)
---
# /review-ui

## Purpose
Screen-level UI review. Dispatches to `ui-review-angular` or `ui-review-react` based on the target app.

## Inputs
- Screen identifier: a route path, a component name, or a file path.
- Target app inferred from the path; can be overridden with `--app=<app>`.

## Required skills
`ui-review-angular` (freightify-web, fb-documents) or `ui-review-react` (admin-frontend, extraction-frontend, quote-ai-frontend).

## Outputs
- Findings grouped by category: layering, state / data, design-system, accessibility, error handling, auth.
- Severity + remediation per finding.

## Related
- Skills: `ui-review-angular`, `ui-review-react`.
