---
name: start
description: The kick-start command a developer runs **once, in their pool** — the `Freightify-AI-Workspace/` folder that
command: /start
arguments: (none)
category: onboarding
on-demand: true
side-effects: POOL MODE (primary) — (1) seeds ./config/git-branch.json from the engine default ONLY if absent; (2) generates Freightify-AI-<PRODUCT>-Workspace.code-workspace at the pool root for each product whose brain is present — CREATE-IF-MISSING ONLY, existing files are never touched. LEGACY workspace-folder mode — scaffolds config/ + README.md and writes ./getting-started.md (fully replaced). NO git operations in any mode. No JIRA calls.
---
# /start

## Purpose
The kick-start command a developer runs **once, in their pool** — the `Freightify-AI-Workspace/` folder that
holds every repo cloned ONCE, flat at its root. `/start` turns that pool into ready-to-open product workspaces:

1. detects which products are present (their brains are cloned),
2. **generates one Cursor workspace file per product** at the pool root
   (`Freightify-AI-<PRODUCT>-Workspace.code-workspace`), and
3. seeds `./config/git-branch.json` if missing.

The developer then opens the workspace file in Cursor (File → Open Workspace from File) — the window shows only
that product's repos. A multi-product developer opens up to 3 windows over the same pool. `/start` is a
**one-time kick-start**: afterwards developers maintain the workspace files by hand (new repo → clone into the
pool → add one `{ "path": "<repo>" }` line → add its branch to `config/git-branch.json`).

## Mode detection
1. **POOL MODE (primary):** the current folder contains one or more `*-ai-brain/` clones directly at its root
   and is NOT named `Freightify-AI-<PRODUCT>-Workspace`. (The developer pool and the admin root both qualify.)
2. **Legacy workspace-folder mode:** the folder is named `Freightify-AI-<PRODUCT>-Workspace` (or contains a
   legacy `<PRODUCT>-Repos/`) — the pre-pool flat/V1 layouts. Kept for backward compatibility only.

## Pool mode — what it does
1. **Seed the branch config (only if missing):**
   ```
   mkdir -p ./config
   [ -f ./config/git-branch.json ] || cp <engine>/scripts/git-branch.default.json ./config/git-branch.json
   ```
   Schema v2 (product-wise): `fallback_branches` + groups `shared` / `EFP` / `RMS` / `ATLAS`. User-maintained;
   NEVER overwritten. One clone per repo in the pool ⇒ one branch per repo — a repo belongs to exactly one group.
2. **Generate the workspace files** — prefer the deterministic generator:
   ```
   bash freightify-ai-workflow/scripts/gen-workspace-files.sh .
   ```
   (Plugin-only install: apply the same rules by hand.) For each product whose `<product>-ai-brain/` is present:
   - Derive the repo list from the brains: exclusives from `<product>-ai-brain/manifest.json` + shared services
     from `shared-ai-brain/consumer-registry.json` where the product is a consumer.
   - Include **only repos that exist on disk** — no dangling entries.
   - Every file starts with: `freightify-ai-workflow` (reference-only engine clone, if present),
     `<product>-ai-brain`, `shared-ai-brain`, `config` — then the product's service repos.
   - Paths are **bare names** (`"skipperroutes"`) — the file lives inside the pool.
   - **CREATE-IF-MISSING ONLY.** An existing workspace file is never regenerated or modified — it belongs to the
     developer after first creation.
3. **Report** — per product: `created (N folders)` / `already present — left untouched` / `skipped (brain not
   cloned)`; plus repos the brains list that aren't cloned yet, and **unmapped repos** (git folders no brain
   knows: *"unmapped: <names> — add manually to a workspace file if needed"*).
4. **No `getting-started.md` in pool mode** — the workspace files are the product. Deep-dive docs live in the
   engine clone every workspace includes (`freightify-ai-workflow/getting-started.md` + `docs/`).

## Pool-mode output (panel)
```
✅ Branch config → ./config/git-branch.json  (<created | already present>)
✅ Workspace files:
     Freightify-AI-EFP-Workspace.code-workspace    <created (26 folders) | already present>
     Freightify-AI-RMS-Workspace.code-workspace    <created | already present | skipped — rms-ai-brain not cloned>
     Freightify-AI-ATLAS-Workspace.code-workspace  <…>
   not cloned yet (add later): <repo names, per product>
   ⚠ unmapped repos: <names> — add manually to a workspace file if needed

Next: open a workspace file in Cursor (File → Open Workspace from File) and run /version, then /triage <KEY>.
```

## Product detection inside an opened workspace
When commands run inside a Cursor multi-root workspace (opened from a `.code-workspace`), the product is the
**single `<product>-ai-brain` among the workspace roots**. Every generated file contains exactly one product
brain, so detection is unambiguous. (Folder-name detection applies only to legacy workspace folders.)

## Legacy workspace-folder mode (backward compatibility)
In a folder named `Freightify-AI-<PRODUCT>-Workspace` (flat layout) or holding `<PRODUCT>-Repos/` (V1):
scaffold `config/` + `README.md` (from `scripts/team-readme.template.md`, only if absent) and render
`scripts/getting-started.template.md` → `./getting-started.md` (always fully replaced). Same rules as before.

## Constraints
- **No git operations in any mode** — never clones, pulls, fetches, or checks anything out. The pool is built
  by the developer with plain `git clone`; missing repos are *reported*, never fetched.
- **Write surface (pool mode):** `./config/git-branch.json` (create-only) + the `.code-workspace` files
  (create-only). Nothing else. Existing files of either kind are never modified.
- **Never calls JIRA.**
- The engine clone in each workspace is **reference-only** (docs + scripts); pushing to it is blocked by GitLab
  protection, and commands always execute via the plugin.

## Related
- Generator: `scripts/gen-workspace-files.sh` (reads `<product>-ai-brain/manifest.json` +
  `shared-ai-brain/consumer-registry.json`).
- Config: `scripts/git-branch.default.json` (v2 schema) — consumed by `/sync-repos` and `base-branch-selection`.
- Onboarding doc: `team-session/Developer-Onboarding.md` (admin workspace) — the end-to-end developer guide.
- Legacy templates: `scripts/team-readme.template.md`, `scripts/getting-started.template.md`,
  `scripts/gen-getting-started.sh`.
