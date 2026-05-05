---
name: gap-report
description: Enumerate documentation gaps in the workspace: missing `.cursor/` files per repo, stale `last-verified` dates, contradictions between the brain and the source `.cursor/` layer
command: /gap-report
arguments: none
category: brain-maintenance
on-demand: true
side-effects: none (read-only)
---
# /gap-report

## Purpose
Enumerate documentation gaps in the workspace: missing `.cursor/` files per repo, stale `last-verified` dates, contradictions between the brain and the source `.cursor/` layer.

## Inputs
none.

## Outputs
- Markdown table per repo: expected files, present / missing, last-verified age.
- Cross-cutting list: stale service cards (> 90 days), contradictions surfaced during the last `/brain-refresh`.

## When to invoke
- Before a doc sprint.
- After a `/brain-refresh` to see what still needs human attention.

## Related
- Commands: `/knowledge-sync`, `/brain-refresh`, `/tbd-report`.
