---
name: node-ts-express-authoring
description: Author a new admin-backend Express route end-to-end: AJV schema → route → controller → service → repository / proxy → tests
scope: admin-backend
inherits: plan-and-implement
composes-rules: [ts-express-layering, layered-architecture, api-contract-first, json-schema-validation, typed-error-handling, error-envelope, structured-logging, testing-conventions, secrets-management]
when-to-invoke: Adding an Express route in admin-backend
sources:
  - admin-backend/.cursor/service-knowledge-base/coding-guidelines.md
  - admin-backend/.cursor/architecture.md
---
# node-ts-express-authoring

## Purpose
Author a new admin-backend Express route end-to-end: AJV schema → route → controller → service → repository / proxy → tests.

## 7 steps

### 1. Understand
Identify target module under `src/modules/` (or equivalent). Check which `BaseRepository` and which downstream `BaseProxy` are involved.

### 2. Plan
- AJV schema for request body + params.
- Route registered in `src/routes.ts` (never ad hoc `app.post` in feature files).
- Middleware: `auditLogger` for mutating routes; `checkPermission('<ROLE_SCOPE>')` for role-gated routes.
- Controller: typed `req.validated` input; delegate to service.
- Service: business logic; typed errors.
- Repository: extends `BaseRepository`.
- Proxy: extends `BaseProxy` (Axios) for downstream calls.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
Order: schema → repo → service → controller → route entry → tests.

### 6. Self-check
- `src/routes.ts` updated; no duplicate route definitions.
- `auditLogger` + `checkPermission` applied correctly.
- Winston logs carry `correlationId`.
- Error envelope contains `code`, `message`, `correlationId`.
- No secrets hardcoded; config reads through the centralised config module.

### 7. Cleanup / regression
`npm test` + `npm run build` pass.

## Related
- Skills: `mongo-schema-change`, `mysql-schema-change`, `proxy-integration`.
- Agents: `architecture-agent`, `security-agent`.
