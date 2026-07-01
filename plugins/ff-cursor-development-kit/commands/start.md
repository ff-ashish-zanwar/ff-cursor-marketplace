---
name: start
description: The first command a new user runs
command: /start
arguments: (none)
category: onboarding
on-demand: true
side-effects: (1) writes ./getting-started.md at the workspace root (product-detected; FULLY REPLACED every run); (2) seeds ./config/git-branch.json from the engine default ONLY if it does not already exist (never overwrites — it is user-maintained config). No JIRA calls.
---
# /start

## Purpose
The first command a new user runs. It **generates the onboarding guide for whichever workspace it's run from**:
1. detects the product from the current workspace,
2. writes a product-specific **`getting-started.md`** at the workspace root, and
3. prints a short orientation and points the user to that file.

The static **`README.md`** at the workspace root exists precisely to send the user here — `/start` is what turns
that one-line pointer into a full, product-correct guide **on the user's own machine**. No `getting-started.md` is
ever hand-distributed; each developer generates their own by running `/start`, so it always matches their product
and the current command set.

## Product detection
Resolve the current product from the workspace, in order:
1. The single `<product>-Repos/` folder present (e.g. `RMS-Repos/` → **RMS**) — the normal single-team case.
2. Else the product brain cloned alongside the service repos (`<product>-ai-brain/`).
3. If more than one product folder is present (the admin's full workspace) → list them and ask which to generate for.

**Never reference a product whose folder isn't present** — a team only ever sees its own product.

## What it does
1. **Detect** `<PRODUCT>` (and `<product>` lower-case) from the workspace per the rules above.
2. **Generate the guide.** Render the getting-started template (`scripts/getting-started.template.md`), substituting
   `{{PRODUCT}}` / `{{product}}`, and write it to **`./getting-started.md`** at the workspace root. The file is
   **always fully replaced** — if one already exists it is overwritten wholesale (no merge, no append), so the guide
   always reflects the current product + command set and any hand-edits are discarded. Prefer the deterministic generator:
   ```
   bash ai-platform/freightify-ai-workflow/scripts/gen-getting-started.sh <PRODUCT> ./getting-started.md
   ```
   If that script isn't reachable (e.g. plugin-only install), render the template directly and write the same file.
3. **Seed the branch config (only if missing).** Ensure `./config/git-branch.json` exists at the workspace root:
   ```
   mkdir -p ./config
   [ -f ./config/git-branch.json ] || cp <engine>/scripts/git-branch.default.json ./config/git-branch.json
   ```
   This is the repo→base-branch map that `/sync-repos` pulls and `/implement` derives feature branches from. Unlike
   `getting-started.md`, it is **user-maintained config** — if it already exists, **leave it untouched** (never
   overwrite; the developer edits it to add repos or change branches). Mention in the panel whether it was created
   or already present.
4. **Orient.** Print the one-screen panel below, and tell the user their full guide is now at `./getting-started.md`.

## Output (the orientation panel)
Print this, with the resolved `<PRODUCT>` / `<product>` filled in:

```
✅ Generated your guide → ./getting-started.md  (open it any time; re-run /start to refresh)
✅ Branch config → ./config/git-branch.json  (<created | already present> — edit it to pin a repo's base branch)

You're in the <PRODUCT> workspace. The AI already knows <PRODUCT>'s services and how they
connect (its brain), so it can route work to the right code and help you ship it.

Two front doors
  • Author a ticket:    /author-ticket "<your idea>"
        Turns a plain-English idea (and any sub-tasks you list) into complete JIRA ticket(s) —
        right project + component + acceptance criteria — ready for a developer to pick up.
  • Build a ticket:     /implement <JIRA-KEY>
        Plan → you approve → code → 14 reviews → you approve. Three gates; you stay in control.

The flow
  /author-ticket  →  JIRA ticket  →  /implement <KEY>  →  reviewed, UNCOMMITTED code
                                                          →  you stage, commit, push, raise the MR

Before your first run (one-time)
  [ ] <product>-ai-brain/ and shared-ai-brain/ cloned alongside your service repos in <PRODUCT>-Repos/
  [ ] Atlassian MCP connected in your IDE  (then there's no JIRA token to set)
  [ ] Product auto-detected from this folder — nothing to configure

More
  • Your full guide:  ./getting-started.md   • Other commands:  /plan /triage /route /bugfix /db-impact /review-ui /sync-repos
  • Full flags + gate replies:  command-flags        • Not sure where a change belongs?  /route "<your question>"
```

## Constraints
- **Product-scoped:** mention only the product(s) actually present; never name another product's brain or repos.
- **Writes at most two files:** `./getting-started.md` (always overwritten) and `./config/git-branch.json` (only if
  absent — never overwritten). It writes nothing else and **never calls JIRA**.
- **Idempotent + always-replace:** re-running fully overwrites `getting-started.md` with a fresh render — safe to run
  any time; never merges or appends. Any manual edits to the generated file are discarded on the next `/start`.
- **`getting-started.md` is a generated artifact** — never hand-edited, never distributed. To change it for everyone,
  edit `scripts/getting-started.template.md` in the engine; users pick it up next time they run `/start`.
- Keep the printed panel to one screen — the depth lives in the generated `getting-started.md`, `command-flags`, and `product-flow.md`.

## Related
- Commands: `/author-ticket`, `/implement`, `/plan`, `/triage`, `/route`, `/sync-repos`. Reference: `command-flags`.
- Generates: root `getting-started.md` (from `scripts/getting-started.template.md` via `scripts/gen-getting-started.sh`); seeds `config/git-branch.json` (from `scripts/git-branch.default.json`) if absent.
- Entry point that sends users here: the static workspace-root `README.md` (`scripts/team-readme.template.md`).
- Config consumed by `/sync-repos` (pulls each repo's base branch) and `/implement` (`base-branch-selection`).
- Docs: `jira-integration/product-flow.md`.
