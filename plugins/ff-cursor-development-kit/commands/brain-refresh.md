---
name: brain-refresh
description: Re-ingest the knowledge base and regenerate all service cards and aggregate brain artifacts
command: /brain-refresh
arguments: none
category: brain-maintenance
on-demand: true
side-effects: rewrites ai-brain/ service cards + cross-service map + ownership matrix + gaps-and-risks; idempotent
---
# /brain-refresh

## Purpose
Re-ingest the knowledge base and regenerate all service cards and aggregate brain artifacts. The 17 repos' `.cursor/` layers are re-read in full.

## Required agents
`knowledge-base-updater-agent`.

## Side effects
- Overwrites every file under `ai-brain/service-cards/`.
- Regenerates `cross-service-map.md`, `building-block-to-services.json`, `ownership-matrix.md`, `gaps-and-risks.md`.
- Updates `last-verified` frontmatter on every refreshed file.
- Idempotent — never duplicates.

## When to invoke
- After significant `.cursor/` changes in any repo.
- Before starting a large `/implement` that spans many services.
- Periodically (e.g., monthly) as hygiene.

## Related
- Commands: `/knowledge-sync`, `/service-card`.
- Agents: `knowledge-base-updater-agent`.
