---
name: service-card
description: Read-only emit of a service card
command: /service-card
arguments: <repo>
category: brain-maintenance
on-demand: true
side-effects: none (read-only)
---
# /service-card <repo>

## Purpose
Read-only emit of a service card. Useful for onboarding, quick reference, or piping into another tool.

## Inputs
- Repo name.

## Outputs
- Contents of `ai-brain/service-cards/<repo>.md` printed to the chat.

## Related
- Commands: `/knowledge-sync` (to refresh it), `/brain-refresh`.
