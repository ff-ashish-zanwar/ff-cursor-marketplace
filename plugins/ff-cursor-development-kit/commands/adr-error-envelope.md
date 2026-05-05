---
name: adr-error-envelope
description: Shortcut to resume ADR-04 (standard error envelope shape)
command: /adr-error-envelope
arguments: [--option A|B|C] [--note "<text>"] [--status ...]
category: brain-maintenance
on-demand: true
resumes: ADR-04
side-effects: appends to ai-brain/decision-log/2026-04-21-adr-04-error-envelope.md
---
# /adr-error-envelope

## Purpose
Shortcut to resume ADR-04 (standard error envelope shape).

## Related
- ADR: [ADR-04](../../ai-brain/decision-log/2026-04-21-adr-04-error-envelope.md).
- Artifacts awaiting: `rules/error-envelope.md`, `skills/error-envelope-authoring.md`, `agents/contract-agent`.
