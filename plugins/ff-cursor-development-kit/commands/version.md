---
name: version
description: Tell the developer **which plugin build they have** and whether it's the latest — so "is my plugin up to date?" has a real answer
command: /version
arguments: (none)
category: onboarding
on-demand: true
side-effects: none — read-only. Prints the installed plugin's version + build; no writes, no JIRA.
---
# /version

## Purpose
Tell the developer **which plugin build they have** and whether it's the latest — so "is my plugin up to date?" has a real answer. Read-only.

## What it reads
Two files that ship inside the plugin (written by `scripts/sync-plugin.sh` on every publish):
- **`.cursor-plugin/plugin.json`** → `version` (semver, bumped each publish).
- **`BUILD-INFO.json`** → `plugin_version`, `engine_commit`, `engine_commit_date`, `built_at`, `engine_repo`.

## What it does
1. **Locate the installed plugin.** Look for `ff-cursor-development-kit/` in this order: the IDE's installed-plugin path (`~/.cursor/**`, `~/.claude/**`), else the workspace's `ai-platform/ff-cursor-marketplace/plugins/ff-cursor-development-kit/`. Use the first found.
2. **Read + print** the installed version and build:
   ```
   Plugin:  ff-cursor-development-kit  v<version>
   Built:   <built_at>  from engine <engine_commit> (<engine_commit_date>)
   Source:  <engine_repo>
   ```
3. **Compare to latest, if reachable (best-effort):**
   - If the marketplace repo is present locally (admin machine): read its `plugins/ff-cursor-development-kit/BUILD-INFO.json` and report `up to date` / `behind — update your plugin` by comparing `plugin_version` (then `engine_commit`).
   - Else print: *"Latest is published in the marketplace — update via your IDE's plugin manager if your version is lower."* Do NOT fabricate a "latest" value you can't read.
4. If `BUILD-INFO.json` is **missing** (an older plugin built before versioning existed), say so and recommend re-installing the current plugin.

## Constraints
- **Read-only** — never writes any file, never calls JIRA, never installs/updates anything (the developer updates via the IDE plugin manager).
- Never invent a "latest" version/commit it hasn't actually read (`no-invented-facts`).
- Product-agnostic — works in any workspace.

## Related
- Build pipeline: `scripts/sync-plugin.sh` (bumps the version + writes `BUILD-INFO.json` on every publish).
- Commands: `/start` (onboarding). Reference: `command-flags`.
