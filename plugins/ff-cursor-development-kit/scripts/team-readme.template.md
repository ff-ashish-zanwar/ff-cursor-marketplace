# Freightify AI Workspace

Welcome. This workspace comes with an AI that already understands your product's services and how they connect,
so it can route work to the right code and help you take a JIRA ticket from **idea → reviewed code**. You install
the tooling once (the Cursor / Claude Code plugin) — you do **not** clone or edit the engine.

## Start here — run `/start`

Open this folder in Cursor / Claude Code and run:

```
/start
```

`/start` detects which product this workspace is for (**EFP / RMS / ATLAS** — from the folder name, so it works in a
brand-new empty folder), **scaffolds the workspace skeleton** (`config/`, this README, your generated guide), and
generates a full, product-specific **`getting-started.md`** right here at the workspace root. All repos — service
repos and the two brains — are cloned flat at this root. Open the guide next — it has the one-time setup
(including the exact `git clone` commands), the two front doors (`/author-ticket` and `/implement`), and the full
command list.

That's the only thing you need to do to get going. Re-run `/start` any time to refresh the guide.

---
_This README is the same in every workspace — it's product-agnostic on purpose, so it can ship to everyone
unchanged. `/start` does all the product-specific work. Source: `freightify-ai-workflow/scripts/team-readme.template.md`._
