---
name: sync-repos
description: Pull the latest on **every** product repo in one shot, so developers stop walking
command: /sync-repos
arguments: none (optional --workspace <path>)
category: workspace
on-demand: true
side-effects: checks out development/dev and runs `git pull` in every product repo; discards stray .DS_Store files; never commits, stashes, force-resets, or touches AI brains
---
# /sync-repos

## Purpose
Pull the latest on **every** product repo in one shot, so developers stop walking
into each repo to `git pull` by hand. Product-agnostic: it syncs whatever
`<Product>-Repos/` folders exist on the developer's machine (EFP, RMS, ATLAS, …).

## Inputs
- None. Auto-detects the workspace root (the folder that contains the `*-Repos`
  directories) by walking up from the current directory.
- Optional: `--workspace <path>` or `FREIGHTIFY_WORKSPACE=<path>` to point at a
  specific workspace root.

## What it does (per repo)
1. **Excludes AI brains** — any repo whose name matches `*ai-brain*` or
   `*ai-knowledge-base*` is never touched.
2. **Stray `.DS_Store`** — if that's the *only* working-tree change, it's
   discarded so the pull can proceed.
3. **Branch choice** — prefers `development`, falls back to `dev`. If neither
   exists on `origin`, the repo is **skipped**.
4. **Checkout + pull** — checks out the branch and runs `git pull --ff-only`.
   A branch switch is reported in the summary for transparency.
5. **Anything else is skipped, never forced** — uncommitted work (beyond
   `.DS_Store`), merge conflicts, auth failures, detached HEAD, etc. cause the
   repo to be skipped. The tool never `commit`s, `stash`es, or `reset --hard`s.

## How to run
This command is a thin wrapper. The orchestrator runs the backing script
`sync-repos.sh` and relays its summary verbatim. The script ships alongside this
command set (the plugin sync copies it into `scripts/`), so resolve its path for
the current context:

- **Engine repo (dev):** `ai-platform/freightify-ai-workflow/scripts/sync-repos.sh`
- **Installed IDE plugin:** the plugin's own `scripts/sync-repos.sh`
- **Fallback if neither is obvious:** locate it, e.g.
  `find . ~/.cursor ~/.claude -name sync-repos.sh -type f 2>/dev/null | head -1`

Then run it (it auto-detects the workspace; no args needed):

```sh
bash <resolved-path>/sync-repos.sh
```

## Outputs
A grouped summary printed to the console:
- **✓ Pulled** — repo, branch, and result (`Already up to date` / `Updating …` /
  any branch switch or `.DS_Store discarded` note).
- **↷ Skipped** — repo + reason (no dev branch, uncommitted changes, pull
  failed, …).
- **🚫 Excluded** — the AI brains, listed so it's clear they were intentionally
  left alone.

## Guarantees
- **Read-mostly & safe.** The only writes are `git pull` (fast-forward only) and
  deleting a stray `.DS_Store`. No developer work is ever lost.
- **Idempotent.** Re-running on an up-to-date workspace is a no-op.
- **On-demand only.** Never schedules or triggers itself.

## Related
- Script: `scripts/sync-repos.sh` (the deterministic engine; see `scripts/README.md`).
