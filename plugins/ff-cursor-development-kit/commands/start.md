---
name: start
description: The first command a new user runs
command: /start
arguments: (none)
category: onboarding
on-demand: true
side-effects: none — read-only orientation; no JIRA calls, no files written
---
# /start

## Purpose
The first command a new user runs. Prints a one-screen, **product-aware** orientation: what the AI can do, the two front doors (`/author-ticket`, `/implement`), the end-to-end flow, the one-time prerequisites, and where to find the full command list. Read-only — it never touches JIRA or writes files.

## Product detection
Resolve the current product from the workspace, in order:
1. The single `<product>-Repos/` folder present (e.g. `RMS-Repos/` → **RMS**) — the normal single-team case.
2. Else the product brain cloned alongside the service repos (`<product>-ai-brain/`).
3. If more than one product folder is present (the admin's full workspace) → list them and ask which to orient for.

**Never reference a product whose folder isn't present** — a team only ever sees its own product.

## Output (the orientation panel)
Print this, with the resolved `<PRODUCT>` / `<product>` filled in:

```
You're in the <PRODUCT> workspace. The AI already knows <PRODUCT>'s services and how they
connect (its brain), so it can route work to the right code and help you ship it.

Two front doors
  • Product — author a ticket:    /author-ticket "<your idea>"
        Turns a plain-English idea into a complete JIRA ticket (right project + component +
        acceptance criteria) — ready for a developer to pick up.
  • Developer — build a ticket:   /implement <JIRA-KEY>
        Plan → you approve → code → 14 reviews → you approve. Three gates; you stay in control.

The flow
  /author-ticket  →  JIRA ticket  →  /implement <KEY>  →  reviewed, UNCOMMITTED code
                                                          →  you stage, commit, push, raise the MR

Before your first run (one-time)
  [ ] <product>-ai-brain/ and shared-ai-brain/ cloned alongside your service repos in <PRODUCT>-Repos/
  [ ] Atlassian MCP connected in your IDE  (then there's no JIRA token to set)
  [ ] Product auto-detected from this folder — nothing to configure

More
  • Other commands:  /plan  /triage  /route  /bugfix  /db-impact  /review-ui  /sync-repos
  • Full flags + gate replies:  command-flags
  • Not sure where a change belongs?  /route "<your question>"
```

## Constraints
- **Product-scoped:** mention only the product(s) actually present; never name another product's brain or repos.
- **Read-only:** never call JIRA, never write files.
- Keep it to one screen — it's an orientation, not a manual. Point to `command-flags` and `product-flow.md` for depth.

## Related
- Commands: `/author-ticket`, `/implement`, `/plan`, `/triage`, `/route`. Reference: `command-flags`.
- Docs: `jira-integration/product-flow.md`. Filesystem onboarding: each team's root `README.md` (see `scripts/gen-team-readme.sh`).
