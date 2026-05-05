---
name: module-development
description: Scaffold a new freightify-web module that participates in module federation and follows the mandatory four-layer structure
scope: freightify-web (Angular) only
inherits: plan-and-implement
composes-rules: [ng-layered-feature-domain-data-ui, ng-module-federation-discipline, ng-rxjs-change-detection, fe-no-business-logic-in-ui, fe-api-response-normalization, fe-auth-interceptor-discipline, frontend-framework-per-app, frontend-design-system-per-app]
when-to-invoke: Creating a brand-new Angular module (new domain) in freightify-web
sources:
  - freightify-web/.cursor/skills/module-development/SKILL.md
  - freightify-web/.cursor/standards/module-development.md
---
# module-development

## Purpose
Scaffold a new freightify-web module that participates in module federation and follows the mandatory four-layer structure.

## Inputs
- New domain name.
- Ownership / business-block alignment.
- Consumer modules (which lazy routes load it).

## Outputs
- `feature/`, `domain/`, `data-access/`, `ui/` folders populated with minimum viable scaffolds.
- `module-federation.config.js` entry.
- `app-routing.module.ts` lazy route.
- NgRx feature slice (if stateful).

## 7 steps

### 1. Understand
Confirm the new module's domain and its owning building-block. Identify consumers that need to lazy-load it.

### 2. Plan
- Folder layout: `feature/`, `domain/`, `data-access/`, `ui/` per standard.
- Module Federation: exposes entry in `module-federation.config.js`.
- Routing: lazy route in `app-routing.module.ts`.
- NgRx: feature slice (if it holds cross-screen state).
- Shared models + API clients.

### 3. Propose

### 4. Pause for human approval
Especially for new modules — they carry a permanent surface.

### 5. Implement
Scaffold bottom-up: data-access → domain → feature → ui.

### 6. Self-check
- Both `module-federation.config.js` AND `app-routing.module.ts` updated (`ng-module-federation-discipline`).
- Layers respect dependency direction.
- OnPush + async pipe used on all new components.

### 7. Cleanup / regression
`ng build` + `ng test`; run the app and verify the lazy route resolves in dev and in a production build.

## Quality gates
- Missing MF or routing registration blocks commit.
- Scaffolds must not include dead files; every generated file must participate in the module.

## Related
- Skills: `feature-development-angular`, `ui-review-angular`, `pr-review`.
- Agents: `architecture-agent`.
