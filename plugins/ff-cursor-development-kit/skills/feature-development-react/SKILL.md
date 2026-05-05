---
name: feature-development-react
description: Add a feature to a React frontend while respecting the target app's framework stack and design system
scope: admin-frontend, extraction-frontend, quote-ai-frontend
inherits: plan-and-implement
composes-rules: [fe-no-business-logic-in-ui, fe-api-response-normalization, fe-no-silent-failures, fe-auth-interceptor-discipline, ts-rtk-query-slices, frontend-framework-per-app, frontend-design-system-per-app]
when-to-invoke: Adding a feature to a React frontend
sources:
  - admin-frontend/.cursor/ARCHITECTURE.md
  - quote-ai-frontend/.cursor/architecture.md
  - extraction-frontend/.cursor/ARCHITECTURE.md
  - freightify-web/.cursor/skills/feature-development/SKILL.md
---
# feature-development-react

## Purpose
Add a feature to a React frontend while respecting the target app's framework stack and design system.

## Inputs
- Target app (admin-frontend / extraction-frontend / quote-ai-frontend).
- Feature spec with acceptance criteria.

## Outputs
- Screens, components, hooks, API slice additions, route entries.
- Tests.

## 7 steps

### 1. Understand
Detect the target app's stack from its service card:
- admin-frontend: CRA + RTK Query + PrimeReact.
- extraction-frontend: Vite + Context + Tailwind.
- quote-ai-frontend: Vite + TanStack + Zustand + shadcn/ui.

### 2. Plan
- Data layer: new RTK Query endpoints (admin-frontend) or TanStack Query hooks (quote-ai-frontend) or `src/api.ts` additions (extraction-frontend).
- Domain layer: `mapFromApi` / `mapToApi`, custom hooks for business logic.
- UI layer: components using the app's design system.
- Routing: route entries in the app's router.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
Data → domain → UI. Respect the app's state management convention.

### 6. Self-check
- `fe-no-business-logic-in-ui` — components are presentational.
- `fe-api-response-normalization` — responses normalized before reaching UI.
- `fe-no-silent-failures` — errors surfaced + reported to Sentry.
- `fe-auth-interceptor-discipline` — token injection respects single-injection-point rule.
- `frontend-design-system-per-app` — no foreign component library introduced.

### 7. Cleanup / regression
Build + test + (if admin-frontend) `npm run build` passes; verify no styling regressions.

## Quality gates
- Don't introduce a second design system.
- Don't add a second state-management library.

## Related
- Skills: `ui-review-react`, `pr-review`.
- Agents: `architecture-agent`, `adr-compliance-agent`.
