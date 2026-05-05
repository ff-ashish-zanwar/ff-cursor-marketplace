---
name: feature-development-angular
description: Add a feature to a freightify-web Angular module without violating layering, module federation, or RxJS hygiene
scope: freightify-web (+ fb-documents for PDF elements)
inherits: plan-and-implement
composes-rules: [ng-layered-feature-domain-data-ui, ng-module-federation-discipline, ng-rxjs-change-detection, fe-no-business-logic-in-ui, fe-api-response-normalization, fe-no-silent-failures, fe-auth-interceptor-discipline, frontend-framework-per-app, frontend-design-system-per-app]
when-to-invoke: Adding a feature inside an existing Angular module
sources:
  - freightify-web/.cursor/skills/feature-development/SKILL.md
  - freightify-web/.cursor/standards/module-development.md
---
# feature-development-angular

## Purpose
Add a feature to a freightify-web Angular module without violating layering, module federation, or RxJS hygiene.

## Inputs
- Target module (e.g., `rates`, `basket`).
- Feature spec with acceptance criteria.

## Outputs
- New components, services, and NgRx actions/effects/selectors in the correct layer.
- Updated tests.

## 7 steps

### 1. Understand
Read the target module's `feature/domain/data-access/ui` layout. Identify which layer each part of the feature belongs to.

### 2. Plan
- `feature/`: new routed sub-module (if needed), lazy-loaded via the module-federation registration.
- `domain/`: new facade methods, selectors, business rules.
- `data-access/`: new NgRx effects, HTTP client methods, mapFromApi / mapToApi.
- `ui/`: new presentational components (OnPush, async pipe).

### 3. Propose
Layered file list + change summary + design-system component choices (PrimeNG).

### 4. Pause for human approval

### 5. Implement
One layer at a time from bottom up: data-access → domain → feature → ui. Commit or stage incrementally.

### 6. Self-check
- `ng-layered-feature-domain-data-ui` direction respected.
- `ng-rxjs-change-detection` applied to every new component.
- If a federated module was added, both `module-federation.config.js` and `app-routing.module.ts` are updated.
- Error paths surface a user-visible message (toast / dialog) and Airbrake report.

### 7. Cleanup / regression
`ng test` and `ng build` pass; no unrelated module regressions.

## Quality gates
- No business logic in `ui/`.
- No ad hoc HTTP calls outside `data-access/`.

## Related
- Skills: `module-development`, `ui-review-angular`, `pr-review`.
- Agents: `architecture-agent`, `code-review-agent`, `observability-agent`.
