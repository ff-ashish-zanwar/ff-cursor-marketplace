---
name: code-refactor
description: Safe, no-behavior-change refactor
scope: workspace
inherits: plan-and-implement
composes-rules: [layered-architecture, testing-conventions, typed-error-handling, no-invented-facts]
when-to-invoke: Restructure without behavior change
sources:
  - freightify-web/.cursor/skills/code-refactor/SKILL.md
---
# code-refactor

## Purpose
Safe, no-behavior-change refactor. Existing tests serve as the behavior contract; they must stay green throughout.

## Inputs
- Target area (module, package, layer, file set).
- Motivation (readability, layer violation, dead code, duplication).

## Outputs
- Structural change with no behavior delta.
- Tests untouched (or only renamed to match new locations).

## 7 steps

### 1. Understand
Characterize the current shape and why it needs to change. Cite the rule or standard being restored (e.g., `layered-architecture`).

### 2. Plan
List the moves: files renamed / split / merged, imports updated, public surface preserved. Enumerate consumers that will see the new shape.

### 3. Propose
Present the final structure and the call-site impact.

### 4. Pause for human approval
Especially important for refactors that touch cross-repo consumers.

### 5. Implement
Move code without changing behavior. No logic edits in the same commit as a move.

### 6. Self-check
- All pre-existing tests still pass without modification (aside from import path renames).
- No change to external contracts (routes, event payloads, function signatures) unless explicitly in the plan.

### 7. Cleanup
Remove dead code that the refactor exposed. Run formatter / linter; commit the result as a follow-up commit.

## Quality gates
- A refactor with a failing test is not a refactor; it is a behavior change. Roll back and re-plan.
- Refactors touching public contracts require `contract-agent` approval.

## Related
- Agents: `architecture-agent`, `test-agent`.
