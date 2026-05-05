---
name: ui-review-react
description: Screen-level review for a React app
scope: admin-frontend, extraction-frontend, quote-ai-frontend
inherits: plan-and-implement (review-only)
composes-rules: [fe-no-business-logic-in-ui, fe-api-response-normalization, fe-no-silent-failures, fe-auth-interceptor-discipline, ts-rtk-query-slices, frontend-design-system-per-app]
when-to-invoke: `/review-ui <screen>` on a React screen
sources:
  - admin-frontend/.cursor/ARCHITECTURE.md
  - quote-ai-frontend/.cursor/architecture.md
---
# ui-review-react

## Purpose
Screen-level review for a React app. Per-app stack is detected from the service card; checks adapt to RTK Query vs TanStack Query vs Context.

## Inputs
- Target screen / route / component tree.
- App identity (admin-frontend / extraction-frontend / quote-ai-frontend).

## Outputs
- Findings grouped by: data layer, domain layer, UI layer, error handling, design-system, a11y.

## Review checks
1. **Data layer** — no raw `fetch` in components; data access through the app's chosen query library.
2. **Domain layer** — business logic lives in hooks / pure functions, not inside JSX.
3. **UI layer** — components are presentational; props flow top-down; memoization applied where renders are expensive.
4. **Error handling** — failures produce user-visible feedback; Sentry `captureException` invoked.
5. **Design system** — components use only the app's library (PrimeReact for admin-frontend; shadcn/ui for quote-ai-frontend; Tailwind primitives for extraction-frontend).
6. **Accessibility** — labels, keyboard navigation, focus trapping in modals.

## Quality gates
- No second design system.
- No bypass of the auth interceptor.

## Related
- Skills: `feature-development-react`, `pr-review`.
- Agents: `code-review-agent`, `architecture-agent`.
