---
name: adr-identity-provider
description: Shortcut to resume ADR-01 work: add context, record an option preference, flip status, or sweep the `awaits-adr: ADR-01` artifacts
command: /adr-identity-provider
arguments: [--option A|B|C] [--note "<text>"]
category: brain-maintenance
on-demand: true
resumes: ADR-01
side-effects: appends to ai-brain/decision-log/2026-04-21-adr-01-identity-provider.md; may flip status
---
# /adr-identity-provider

## Purpose
Shortcut to resume ADR-01 work: add context, record an option preference, flip status, or sweep the `awaits-adr: ADR-01` artifacts.

## Inputs
- Optional `--option <A|B|C>` to record leaning.
- Optional `--note "<text>"` to append to the Context or Decision section.
- Optional `--status <proposed|accepted|rejected|superseded>`.

## Side effects
- Appends to the ADR file (never rewrites).
- If status flips to `accepted`, prints the list of artifacts carrying `awaits-adr: ADR-01` so they can be swept.

## Related
- Commands: `/adr`, `/adr-status`.
- ADR: [ADR-01](../../ai-brain/decision-log/2026-04-21-adr-01-identity-provider.md).
- Artifacts awaiting: `rules/auth-provider-per-service-family.md`, `agents/security-agent`.
