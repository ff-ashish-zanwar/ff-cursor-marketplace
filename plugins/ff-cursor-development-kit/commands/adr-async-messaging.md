---
name: adr-async-messaging
description: Shortcut to resume ADR-02 (async messaging standard)
command: /adr-async-messaging
arguments: [--option A|B|C] [--note "<text>"] [--status ...]
category: brain-maintenance
on-demand: true
resumes: ADR-02
side-effects: appends to ai-brain/decision-log/2026-04-21-adr-02-async-messaging.md
---
# /adr-async-messaging

## Purpose
Shortcut to resume ADR-02 (async messaging standard). Same shape as `/adr-identity-provider`.

## Related
- Commands: `/adr`, `/adr-status`.
- ADR: [ADR-02](../../ai-brain/decision-log/2026-04-21-adr-02-async-messaging.md).
- Artifacts awaiting: `rules/async-transport-per-service-family.md`, `skills/async-transport-selector.md`, `agents/async-transport-agent`.
