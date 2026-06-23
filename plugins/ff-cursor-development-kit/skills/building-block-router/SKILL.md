---
name: building-block-router
description: Resolve a natural-language task description into building-block → module → sub-module → owning service(s) using `building-block-to-services.json` and `ai-agent-routing-guide.md`
scope: pipeline-support
inherits: plan-and-implement
composes-rules: [knowledge-retrieval-order, no-invented-facts]
when-to-invoke: Consumed by `router-agent` after intake
sources:
  - efp-ai-knowledge-base/01-EFP/ai-agent-routing-guide.md
  - efp-ai-knowledge-base/ai-brain/building-block-to-services.json
  - efp-ai-knowledge-base/dictionaries/lookups.json
---
# building-block-router

## Purpose
Resolve a natural-language task description into building-block → module → sub-module → owning service(s) using `building-block-to-services.json` and `ai-agent-routing-guide.md`.

## Inputs
- Parsed ticket intake (from `jira-ticket-parser`) or a free-text description.

## Outputs
```json
{
  "building_blocks": ["Tariff Administration"],
  "modules": ["Freight Rate Level Charges"],
  "sub_modules": [],
  "owning_services": ["fb-rates-go"],
  "owning_data_stores": ["mongodb:rates.tariff_freight_rate_level_charges"],
  "related_services": ["admin-backend"],
  "awaits_adrs": ["ADR-03"]
}
```

## 7 steps

### 1. Understand
Extract keywords from the intake. Resolve acronyms via `lookups.json`.

### 2. Plan
- Match keywords against `building-block-to-services.json` aliases + module names.
- For each match, list owning services + data stores.
- Flag any `awaits_adr` entries in the JSON.
- Identify `related_services` via the ownership matrix (services that call the owners).

### 3. Propose
Emit the routing decision with citations (which alias matched, which module entry, which ADRs scope this area).

### 4. Pause for human approval

### 5. Implement
Write the routing to `freightify-ai-brain/ai-brain/task-history/<KEY>.md` under `## Routing`.

### 6. Self-check
- No building-block assigned without a keyword match or an explicit ticket label.
- No service assigned that is not listed under the matched module.
- `TBD — <question>` where the intake is ambiguous.

### 7. Cleanup
Read-only skill.

## Related
- Agents: `router-agent`, `planner-agent`.
