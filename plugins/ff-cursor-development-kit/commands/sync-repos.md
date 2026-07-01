---
name: sync-repos
description: Pull the latest base branch on **every** product repo in one shot, so developers stop walking
command: /sync-repos
arguments: none (optional --workspace <path>, --dry-run)
category: workspace
on-demand: true
side-effects: checks out each repo's configured base branch and runs `git pull --ff-only` in every product repo; discards stray .DS_Store files; never commits, stashes, force-resets, or touches AI brains
---
# /sync-repos

## Purpose
Pull the latest base branch on **every** product repo in one shot, so developers stop walking
into each repo to `git pull` by hand — and so everyone is on the exact base branch each repo
derives feature branches from before starting `/implement`. Product-agnostic: it syncs whatever
`<Product>-Repos/` folders exist on the developer's machine (EFP, RMS, ATLAS, …).

## Inputs
- None. Auto-detects the workspace root (the folder that contains the `*-Repos`
  directories) by walking up from the current directory.
- **`config/git-branch.json`** at the workspace root — the repo→base-branch map + `fallback_branches`
  (seeded by `/start` if absent; user-maintained). Read with jq → python3 → grep (no hard dependency).
- Optional: `--workspace <path>` or `FREIGHTIFY_WORKSPACE=<path>` to point at a
  specific workspace root; `--dry-run` to preview the chosen branch per repo without any checkout/pull.

## What it does (per repo)
1. **Excludes AI brains** — any repo whose name matches `*ai-brain*` or
   `*ai-knowledge-base*` is never touched.
2. **Stray `.DS_Store`** — if that's the *only* working-tree change, it's
   discarded so the pull can proceed.
3. **Branch choice — config first, then fallback:**
   - If the repo is listed in `config/git-branch.json` → use that branch. If that branch does not exist
     on `origin`, the repo is **skipped** (surfaced as a failure, so a bad pin is visible).
   - If the repo is **not** listed → walk `fallback_branches` in order (default
     `development → dev → IMD-Development → imd-dev`) and use the first that exists on `origin`.
     If none exist, the repo is **skipped**.
   - If the config file is missing entirely → every repo just uses the fallback sequence.
4. **Checkout + pull** — checks out the branch and runs `git pull --ff-only`.
   A branch switch is reported in the summary for transparency.
5. **Anything else is skipped, never forced** — uncommitted work (beyond
   `.DS_Store`), merge conflicts, auth failures, detached HEAD, a mapped branch missing on origin,
   etc. cause the repo to be skipped. The tool never `commit`s, `stash`es, or `reset --hard`s.

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
A per-repo status report printed to the console — **every repo is accounted for** with its branch and a
SUCCESS/FAILURE outcome:
- **✓ SUCCESS** — product, repo, branch, and result (`Already up to date` / `Updating …` /
  any branch switch or `.DS_Store discarded` note). Under `--dry-run`: the branch it *would* checkout+pull.
- **✗ FAILURE / SKIPPED** — product, repo, branch (or `-` if none resolved), and reason (mapped branch missing
  on origin, none of the fallback branches exist, uncommitted changes, pull failed, …).
- **🚫 Excluded** — the AI brains, listed so it's clear they were intentionally left alone.

A one-line header shows which `config/git-branch.json` was used (or that none was found and the fallback applies).

## Guarantees
- **Read-mostly & safe.** The only writes are `git pull` (fast-forward only) and
  deleting a stray `.DS_Store`. No developer work is ever lost.
- **Idempotent.** Re-running on an up-to-date workspace is a no-op.
- **On-demand only.** Never schedules or triggers itself.

## Related
- Script: `scripts/sync-repos.sh` (the deterministic engine; see `scripts/README.md`).
- Config: `config/git-branch.json` at the workspace root (seed: `scripts/git-branch.default.json`; seeded by `/start`).
- Same config drives `/implement`'s base branch (`base-branch-selection` / `base-branch-picker-agent`), so the branch
  you sync and the branch you build from never diverge.
