---
name: brain-refresh
description: **Admin-only.** Refresh a brain by (a) re-reading every in-scope repo's `.cursor/` **and** (b) **mining the human corrections** captured in task-history (`## Corrections`) — so the brain gets *more accurate* over time, not just re-derived
command: /brain-refresh
arguments: <EFP|RMS|ATLAS|shared|all> --role admin
category: brain-maintenance
audience: admin
admins: [ashish.zanwar@freightify.com]
on-demand: true
side-effects: discovers repos in the product folder(s), opens a PR on the targeted brain repo with regenerated graph/index/wiring/routing (+ cards for newly-added repos); never auto-merges; never overwrites hand-written notes; never deletes a card
---
# /brain-refresh <target>

## Purpose
**Admin-only.** Refresh a brain by (a) re-reading every in-scope repo's `.cursor/` **and** (b) **mining the human corrections** captured in task-history (`## Corrections`) — so the brain gets *more accurate* over time, not just re-derived. The corrections are the feedback loop: where the AI guessed and a human fixed it, the fix flows back into the brain.

## Authorization
`audience: admin` → governed by [`admin-only`](../rules/admin-only.md). The list of admins is **hardcoded in this command's `admins:` frontmatter** (currently `ashish.zanwar@freightify.com`) — there is no separate allowlist file. The command resolves the caller's real identity (Atlassian MCP email/`accountId`, else `git user.email`) and **refuses unless that identity is in the `admins:` list AND `--role admin` was supplied**. The flag alone is never sufficient. To add or remove an admin, edit the `admins:` list above and re-run `scripts/sync-plugin.sh`.

## Targets
| Target | Refreshes | Scope |
|---|---|---|
| `EFP` / `RMS` / `ATLAS` | `<product>-ai-brain` | that product's repos' `.cursor/` + its task-history corrections |
| `shared` | `shared-ai-brain` | **cross-product** — re-detects shared services across ALL product folders; rebuilds `consumer-registry.json` + `graph/cross-product-edges.jsonl` (needs the full/admin workspace) |
| `all` | every product brain, **then** `shared` | products first (shared depends on their graphs) |

## What it does (per target brain)
1. **Discover the repos (reconcile disk ↔ brain).** Scan every in-scope `<PRODUCT>-Repos/` folder for service repos (exclude `*-ai-brain` / `*-ai-knowledge-base`) and reconcile against the brain's `manifest.json`:
   - **New repo** (on disk, no card yet) → generate a card + graph nodes (a low-confidence stub if it has no `.cursor/`), and list it in the PR summary. *This is what picks up a repo the team just added.*
   - **Missing repo** (carded, but the folder is gone) → **flag in `gaps.md`** as possibly-removed (with its last-seen `manifest` commit). **Never delete** the card, its history, or its edges.
   - Record stack / owner / HEAD for every present repo.
2. **Re-extract EVERY present repo from `.cursor/` — fresh, no cache.** Regenerate `graph/{nodes,edges}.jsonl`, validated against `brain-schema/`. Because every in-scope repo is re-read on every run, **any `.cursor/*.md` a team changed is picked up automatically** — you don't tell it which repos changed.
3. **Mine corrections** — read every `task-history/*.md` `## Corrections` for this product. For each (`ai_value → human_value` + rationale), apply it as a **higher-confidence signal**: e.g. a building-block/routing correction updates `routing.json` + the `belongs_to` edges; a *repeated* correction strengthens the mapping. Each applied correction **cites the task-history file** it came from (provenance — `no-invented-facts`).
4. **Re-derive** `index/`, `wiring/`, `routing.json`, `gaps.md`, and bump `manifest.json` (per-repo synced commit) from the graph.
5. **Open a PR** on the brain repo (one PR per brain) with a plain-English *"what changed"* summary — including **repos added**, **repos flagged missing**, and **which corrections were applied**. **Never auto-merges. Never overwrites hand-written notes** — auto-generated facts and human notes stay in separate files.
6. **Report + tell you how to distribute** (see below).

## After the PR — how the refreshed brain reaches the team
The brain is distributed through the **brain repo**, NOT the plugin (brains are not shipped in the plugin — the plugin carries only the product-agnostic engine). So the command finishes by printing:

> ✅ Brain PR raised on `<product>-ai-brain` (added: `<new repos>` · flagged missing: `<gone repos>`).
> **To distribute:** review + **merge the PR**, then teams run `git pull` on `<product>-ai-brain`.
> **The plugin is a separate channel** — it does not contain the brains. Only run `scripts/sync-plugin.sh` + push the marketplace when the **engine** (commands/agents/rules/skills) changed, not for a brain refresh.

## When to invoke
- After a team **adds repos**, changes `.cursor/*.md` in one or more repos, or once a batch of task-history corrections has accumulated.
- Periodically (e.g. monthly) as hygiene. Admin only.

## Related
- Rules: `admin-only`, `no-invented-facts`, `knowledge-retrieval-order`. Admins: hardcoded in this command's `admins:` frontmatter.
- Commands: `/knowledge-sync` (one repo), `/service-card`.
- Docs: `jira-integration/audit-trail.md` (the `## Corrections` log). Schema: `brain-schema/`.
