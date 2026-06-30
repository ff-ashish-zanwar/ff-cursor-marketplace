---
name: ticket-authoring
description: Author a complete, `/implement`-ready JIRA ticket from a free-text product idea, grounded in the AI-brains
scope: pipeline-support (product)
inherits: plan-and-implement
composes-rules: [no-invented-facts, ticket-completeness, implement-intake-format, human-approval-gates, jira-write-permissions, no-pii-in-logs]
when-to-invoke: Consumed by `/author-ticket` across `product-intake-agent`, `ticket-composer-agent`, `jira-writer-agent`
sources:
  - shared-ai-brain/consumer-registry.json
  - <product>-ai-brain/routing.json
  - <product>-ai-brain/index/<repo>.md
---
# ticket-authoring

## Purpose
Author a complete, `/implement`-ready JIRA ticket from a free-text product idea, grounded in the AI-brains. The product-lane counterpart of `plan-and-implement`. Every drafted field is either brain-grounded (cited) or marked `TBD — <question>`.

## Inputs
- Confirmed idea (from `product-intake-agent`).
- Routing result (building block → product → repos + blast radius, from `router-agent` over `routing.json` + `consumer-registry.json`).
- Project/board/component resolved from `jira-projects.json`.

## Outputs
A ticket draft in [`implement-intake-format`](../rules/implement-intake-format.md), written into the task-history `## Authoring` section, ready for `ticket-completeness` and Gate-P.

## 7 steps
### 1. Understand
Read the confirmed idea + the routed repos' brain `index/` cards. Resolve acronyms via `dictionaries/lookups.json`.

### 2. Plan
Map idea → building block → repos → project/board/component. Identify blast radius (shared-service consumers) so the ticket flags cross-product impact.

### 3. Propose / draft
Compose title, problem statement, acceptance criteria (≥1, testable, cited), reproduction steps (if bug). Unknowns → `TBD — <question>`, never invented.

### 4. Pause for human approval (Gate-P)
Product user reviews the draft + project (overridable) + board (asked) + component → `approve | revise | reject`.

### 5. Implement
On `approve` + create mode: `jira-writer-agent` creates the issue and renames the record to `<KEY>.md`. Copy-paste mode: emit the formatted ticket, no JIRA write.

### 6. Self-check
- Draft conforms to `implement-intake-format` and passes `ticket-completeness`.
- No PII/secrets; no invented acceptance criteria.
- Project auto-resolved + overridable; board explicitly chosen.

### 7. Cleanup
Stamp `last-phase`; the `<KEY>.md` is now the shared lifecycle record `/implement` will append to.

## Related
- Agents: `product-intake-agent`, `ticket-composer-agent`, `jira-writer-agent`, `router-agent`, `ticket-completeness-agent`.
- Commands: `/author-ticket` → `/implement`.
