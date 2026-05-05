---
name: ui-review-angular
description: Screen-level review for an Angular app
scope: freightify-web, fb-documents
inherits: plan-and-implement (review-only)
composes-rules: [ng-layered-feature-domain-data-ui, ng-rxjs-change-detection, fe-no-business-logic-in-ui, fe-no-silent-failures, fe-auth-interceptor-discipline, frontend-design-system-per-app]
when-to-invoke: `/review-ui <screen>` on an Angular screen
sources:
  - freightify-web/.cursor/skills/ui-review/SKILL.md
---
# ui-review-angular

## Purpose
Screen-level review for an Angular app. Catches change-detection, accessibility, and layering issues that a diff review might miss.

## Inputs
- Target screen / route / component tree.

## Outputs
- Findings grouped by category: layering, change detection, a11y, design-system, error handling.
- Severity + remediation per finding.

## Review checks
1. **Layering** — every component has `ChangeDetectionStrategy.OnPush`; `data-access/` calls are not in templates; domain logic is not in the template.
2. **RxJS hygiene** — templates use the `async` pipe; no manual `.subscribe()` without `takeUntilDestroyed`/`takeUntil`; `shareReplay` on multi-binding observables.
3. **Design system** — all interactive elements come from PrimeNG; custom components wrap PrimeNG primitives.
4. **Accessibility** — form labels, ARIA attributes, keyboard navigation, focus management.
5. **Error handling** — errors surface via toast/dialog; Airbrake `captureException` called for unexpected errors.
6. **Auth** — no manual token injection inside templates or component logic.

## Quality gates
- Direct `HttpClient` injection in `ui/` blocks the review.
- Missing form labels block the review.

## Related
- Skills: `feature-development-angular`, `pr-review`.
- Agents: `code-review-agent`, `architecture-agent`.
