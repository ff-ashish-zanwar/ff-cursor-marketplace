---
name: brain-refresh
description: **Admin-only.** Refresh a brain by (a) re-reading every in-scope repo's `.cursor/` **and** (b) **mining the human corrections** captured in task-history (`## Corrections`) — so the brain gets *more accurate* over time, not just re-derived
command: /brain-refresh
arguments: <EFP|RMS|ATLAS|shared|all> --role admin
category: brain-maintenance
audience: admin
on-demand: true
side-effects: opens a PR on the targeted brain repo with regenerated graph/index/wiring/routing; never auto-merges; never overwrites hand-written notes
---
# /brain-refresh <target>

## Purpose
**Admin-only.** Refresh a brain by (a) re-reading every in-scope repo's `.cursor/` **and** (b) **mining the human corrections** captured in task-history (`## Corrections`) — so the brain gets *more accurate* over time, not just re-derived. The corrections are the feedback loop: where the AI guessed and a human fixed it, the fix flows back into the brain.

## Authorization
`audience: admin` → governed by [`admin-only`](../rules/admin-only.md). The command resolves the caller's real identity (Atlassian MCP email/`accountId`, else `git user.email`) and **refuses unless it is in `admin-allowlist.json` AND `--role admin` was supplied**. The flag alone is never sufficient.

## Targets
| Target | Refreshes | Scope |
|---|---|---|
| `EFP` / `RMS` / `ATLAS` | `<product>-ai-brain` | that product's repos' `.cursor/` + its task-history corrections |
| `shared` | `shared-ai-brain` | **cross-product** — re-detects shared services across ALL product folders; rebuilds `consumer-registry.json` + `graph/cross-product-edges.jsonl` (needs the full/admin workspace) |
| `all` | every product brain, **then** `shared` | products first (shared depends on their graphs) |

## What it does (per target brain)
1. **Inventory** the in-scope repos (stack / owner / HEAD).
2. **Re-extract** each repo from `.cursor/` (the generation pipeline) → regenerate `graph/{nodes,edges}.jsonl`, validated against `brain-schema/`.
3. **Mine corrections** — read every `task-history/*.md` `## Corrections` for this product. For each (`ai_value → human_value` + rationale), apply it as a **higher-confidence signal**: e.g. a building-block/routing correction updates `routing.json` + the `belongs_to` edges; a *repeated* correction strengthens the mapping. Each applied correction **cites the task-history file** it came from (provenance — `no-invented-facts`).
4. **Re-derive** `index/`, `wiring/`, `routing.json`, `gaps.md` from the graph.
5. **Open a PR** on the brain repo (one PR per brain) with a plain-English *"what changed + which corrections were applied"* summary. **Never auto-merges. Never overwrites hand-written notes** — auto-generated facts and human notes stay in separate files.

## When to invoke
- After significant `.cursor/` changes, or once a batch of task-history corrections has accumulated.
- Periodically (e.g. monthly) as hygiene. Admin only.

## Related
- Rules: `admin-only`, `no-invented-facts`, `knowledge-retrieval-order`. Config: `admin-allowlist.json`.
- Commands: `/knowledge-sync` (one repo), `/service-card`.
- Docs: `jira-integration/audit-trail.md` (the `## Corrections` log). Schema: `brain-schema/`.
