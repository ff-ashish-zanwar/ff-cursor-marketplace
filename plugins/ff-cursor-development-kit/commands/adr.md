---
name: adr
description: Scaffold a new Architectural Decision Record using `_template.md`
command: /adr
arguments: "<title>"
category: brain-maintenance
on-demand: true
side-effects: writes a new file under ai-brain/decision-log/; appends to decision-log/README.md
---
# /adr "<title>"

## Purpose
Scaffold a new Architectural Decision Record using `_template.md`. Assigns the next ADR number, sets today's date, creates the file, and registers it in `decision-log/README.md`.

## Inputs
- Quoted title, e.g. `/adr "Consolidate observability storage"`.

## Outputs
- New file `ai-brain/decision-log/YYYY-MM-DD-adr-NN-<slug>.md` with status `proposed`.
- Row appended to the Open ADRs table in `decision-log/README.md`.
- Printed path so the developer can immediately start editing.

## Naming
- `NN` is the next zero-padded integer after the highest existing ADR.
- `<slug>` = lowercased title with non-alphanumerics replaced by `-`, truncated at 40 chars.

## When to invoke
- A recurring architectural debate crosses the threshold of "let's decide this once."
- A `TBD` in the brain expands into a full tradeoff analysis.

## Related
- Commands: `/adr-status`, `/tbd-report`.
- Artifacts: `ai-brain/decision-log/_template.md`, `ai-brain/decision-log/README.md`.
