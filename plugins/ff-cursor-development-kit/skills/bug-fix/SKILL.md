---
name: bug-fix
description: Root-cause-first bug flow
scope: workspace (RCA-first)
inherits: plan-and-implement
composes-rules: [knowledge-retrieval-order, ticket-completeness, testing-conventions, test-coverage-floor, typed-error-handling, human-approval-gates]
when-to-invoke: `/bugfix <JIRA-KEY>` and any defect work
sources:
  - freightify-web/.cursor/skills/bug-fix/SKILL.md
---
# bug-fix

## Purpose
Root-cause-first bug flow. Reproduce the defect, identify the root cause with evidence, fix it, and add a regression test that would fail without the fix.

## Inputs
- Bug ticket with **reproduction steps** (enforced by `ticket-completeness`).
- Access to the affected repo(s).

## Outputs
- Reproduction confirmed (or failed, with a reason).
- Root-cause note recorded in `task-history/<KEY>.md`.
- A minimal fix.
- At least one regression test that fails without the fix.

## 7 steps

### 1. Understand
Read the ticket. Apply `knowledge-retrieval-order`. Restate the observed vs expected behavior. Confirm reproduction steps.

### 2. Plan / RCA
Reproduce the bug locally. Trace to the root cause — not the symptom. Record:
- Smallest failing input.
- Evidence (log lines, stack trace, failing test output, collection query).
- Hypothesis for the root cause.

### 3. Propose the fix
Smallest change that addresses the root cause. If the RCA shows the issue is elsewhere, stop and raise a new ticket rather than patching near the symptom.

### 4. Pause for human approval
Emit RCA + proposed fix. Await `approve`.

### 5. Implement
Apply the fix. Add a regression test that fails without the fix and passes with it.

### 6. Self-check
- Regression test was red before the fix, green after.
- No unrelated changes.
- Rule `typed-error-handling` and the affected service's family rules respected.

### 7. Cleanup / regression
Run the full test target for the affected repo. Confirm no sibling tests regressed.

## Quality gates
- Fixing the symptom without RCA is rejected at step 4.
- A bug fix without a regression test is rejected at step 7.

## Related
- Agents: `rca-agent`, `coder-agent`, `test-agent`.
- Commands: `/bugfix`.
