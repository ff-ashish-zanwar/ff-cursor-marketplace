---
name: plan-and-implement
description: The canonical 7-step meta-pattern that every downstream skill inherits
scope: meta (backbone of every other skill and of /implement)
composes-rules: [knowledge-retrieval-order, no-invented-facts, human-approval-gates, prompt-governance]
when-to-invoke: Any non-trivial change. Every other skill inherits this shape.
sources:
  - freightify-web/.cursor/skills/feature-development/SKILL.md
  - freightify-web/.cursor/skills/bug-fix/SKILL.md
  - freightify-web/.cursor/skills/module-development/SKILL.md
  - freightify-ai-workflow/walkthrough-findings.md
---
# plan-and-implement

## Purpose
The canonical 7-step meta-pattern that every downstream skill inherits. Backbone of the `/implement` pipeline.

## Inputs
- Task description (usually a JIRA ticket, sometimes free text).
- Access to `ai-brain/` and the affected repos.

## Outputs
- A plan document.
- Code changes on a feature branch (only after approval).
- A self-check report referencing the rules checked.

## 7 steps

### 1. Understand the requirement
Read the task. Apply `knowledge-retrieval-order`. Restate the requirement in your own words. Identify unknowns and list them as `TBD — <question>`.

### 2. Plan / list root causes / impact & risk analysis
- Which building block(s), services, data stores are involved? Consult `ai-brain/building-block-to-services.json` and `ownership-matrix.md`.
- What is the risk surface: tenant isolation? schema migration? cross-service contract? auth?
- What is the rollback plan if the change fails?

### 3. Propose the approach
Write the plan: affected files per repo, new/changed APIs, data-model impact, test plan, rollback plan. Include ADR references where the change is blocked or scoped by an open ADR.

### 4. Pause for human approval
Emit the plan and stop. Accept `approve` / `reject` / `revise <notes>` only.

### 5. Implement the approved phase only
No silent scope expansion. Follow every rule that applies to the surface being changed. Produce minimal diff.

### 6. Self-check against rules and standards
Before signaling completion, re-read every rule listed in `composes-rules` for the specific scope and verify compliance. Record the check in the task-history.

### 7. Cleanup / regression check
Run the repo's test command. Re-run related paths by hand where tests are thin. Confirm no unrelated files are touched. Remove any scaffolding left from step 5.

## Quality gates
- No code written before step 4's `approve`.
- No commit without step 7's regression pass.
- Every step's output is recorded in `<product>-ai-brain/task-history/<JIRA-KEY>.md`.

## Composed rules
All workspace-universal rules apply by default. Downstream skills narrow the rule set per scope.

## Related
- Skills: every other skill in this directory.
- Agents: `planner-agent`, `coder-agent`.
- Rules: `human-approval-gates`, `knowledge-retrieval-order`.
