---
name: knowledge-sync
description: Refresh a single service card without running a full `/brain-refresh`
command: /knowledge-sync
arguments: <repo>
category: brain-maintenance
on-demand: true
side-effects: rewrites ai-brain/service-cards/<repo>.md; may update ownership-matrix and cross-service-map if dependencies shift
---
# /knowledge-sync <repo>

## Purpose
Refresh a single service card without running a full `/brain-refresh`. Cheap and narrow.

## Inputs
- Repo name (must match a sibling of `efp-ai-knowledge-base/`).

## Required agents
`knowledge-base-updater-agent` (single-repo mode).

## Side effects
- Overwrites `ai-brain/service-cards/<repo>.md`.
- If the repo's outbound dependencies / events changed, may update `cross-service-map.md` and `ownership-matrix.md` rows for that repo only.
- `last-verified` bumped on the refreshed card.

## When to invoke
- After editing `<repo>/.cursor/` files.
- When a service card carries stale TBDs and the underlying `.cursor/` layer has been filled in.

## Related
- Commands: `/brain-refresh`, `/service-card`, `/gap-report`.
