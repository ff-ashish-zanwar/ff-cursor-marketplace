---
name: adr-llm-vendor
description: Shortcut to resume ADR-05 (LLM vendor selection)
command: /adr-llm-vendor
arguments: [--option A|B|C] [--note "<text>"] [--status ...]
category: brain-maintenance
on-demand: true
resumes: ADR-05
side-effects: appends to ai-brain/decision-log/2026-04-21-adr-05-llm-vendor.md
---
# /adr-llm-vendor

## Purpose
Shortcut to resume ADR-05 (LLM vendor selection).

## Related
- ADR: [ADR-05](../../ai-brain/decision-log/2026-04-21-adr-05-llm-vendor.md).
- Artifacts awaiting: `rules/llm-vendor-per-service.md`, `skills/llm-prompt-authoring.md`, `agents/prompt-review-agent`.
