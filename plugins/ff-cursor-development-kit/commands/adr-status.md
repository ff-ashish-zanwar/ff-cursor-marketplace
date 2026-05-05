---
name: adr-status
description: Report the current state of every ADR in `ai-brain/decision-log/` plus the list of artifacts (`rules/`, `skills/`, `commands/`, `agents/`) currently carrying `awaits-adr: ADR-NN` frontmatter
command: /adr-status
arguments: none
category: brain-maintenance
on-demand: true
side-effects: none (read-only)
---
# /adr-status

## Purpose
Report the current state of every ADR in `ai-brain/decision-log/` plus the list of artifacts (`rules/`, `skills/`, `commands/`, `agents/`) currently carrying `awaits-adr: ADR-NN` frontmatter.

## Outputs
Per ADR:
- ID, title, status, date, days since last update.
- Options considered + current leaning (if any).
- Artifacts awaiting decision — grouped by type.

Cross-cutting:
- ADR aging report (time in `proposed` status).
- Sweep candidates: if an ADR is marked `accepted`, list every `awaits-adr` artifact that still needs updating.

## Typical uses
- Weekly hygiene review.
- Before a planning meeting about an architectural question.
- After flipping an ADR to `accepted` to see the sweep work.

## Related
- Commands: `/adr`, `/adr-identity-provider`, `/adr-async-messaging`, ... (per-ADR shortcuts).
- Artifacts: `ai-brain/decision-log/`, every rule/skill/command/agent with `awaits-adr` frontmatter.
