---
name: jira-ticket-parser
description: Convert a JIRA ticket JSON payload into a structured intake the rest of the pipeline consumes
scope: pipeline-support
inherits: plan-and-implement
composes-rules: [no-invented-facts, ticket-completeness, no-pii-in-logs]
when-to-invoke: Consumed by `jira-agent` at the start of every `/implement`, `/bugfix`, `/plan`, `/triage`
sources:
  - efp-ai-knowledge-base/01-EFP/ai-agent-routing-guide.md
---
# jira-ticket-parser

## Purpose
Convert a JIRA ticket JSON payload into a structured intake the rest of the pipeline consumes. Evidence-grounded: every extracted field cites the ticket field it came from.

## Inputs
- Raw JIRA ticket JSON (fetched by `jira-agent` using developer-local `JIRA_API_TOKEN`).

## Outputs
JSON-shaped intake:
```json
{
  "key": "EFP-1234",
  "title": "...",
  "status": "In Progress",
  "assignee": "email",
  "intent": "feature|bug|refactor|ops",
  "entities": ["FRLC", "fb-rates-go", ...],
  "acceptance_criteria": ["..."],
  "reproduction_steps": ["..."],
  "affected_building_blocks": ["Tariff Administration"],
  "priority": "Medium",
  "labels": [...]
}
```

## 7 steps

### 1. Understand
Read the ticket fields. Resolve every acronym via `dictionaries/lookups.json`.

### 2. Plan
Map JIRA fields to intake shape:
- `summary` → `title`.
- `status.name` → `status`.
- `assignee.emailAddress` → `assignee`.
- Ticket type + body → `intent` inference.
- Body parsed for "Acceptance" / "Steps to reproduce" sections.

### 3. Propose / restate
Emit the parsed intake + the assistant's paraphrase of the requirement.

### 4. Pause for human approval
Developer confirms the restatement is faithful before the pipeline proceeds.

### 5. Implement
Write the intake to `freightify-ai-brain/ai-brain/task-history/<KEY>.md` under `## Intake`.

### 6. Self-check
- Every field cites either a ticket field or `TBD — <question>`.
- No PII / secrets in the intake.
- Completeness check against `ticket-completeness` rule; list missing fields.

### 7. Cleanup
None — read-only skill.

## Related
- Agents: `jira-agent`, `ticket-completeness-agent`, `router-agent`.
