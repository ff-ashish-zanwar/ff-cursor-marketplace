---
name: tbd-report
description: Enumerate every `TBD` entry across the brain with the specific question that caused each, sorted by age
command: /tbd-report
arguments: none
category: brain-maintenance
on-demand: true
side-effects: none (read-only)
---
# /tbd-report

## Purpose
Enumerate every `TBD` entry across the brain with the specific question that caused each, sorted by age. Complements `/gap-report` (which is about missing files and stale dates; `/tbd-report` is about known-unknown facts that were recorded).

## Inputs
none.

## Outputs
Markdown table: file | line | TBD text | age | owning repo.

Sections:
- **Fresh (< 30 days)**: typically fine, just unresolved.
- **Medium (30–90 days)**: candidates for a doc pass.
- **Stale (> 90 days)**: surface in the next standup; either resolve or delete.

## When to invoke
- Weekly / monthly hygiene.
- Before generating an ADR candidate list.

## Related
- Commands: `/gap-report`, `/brain-refresh`.
