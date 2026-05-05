---
name: feature-development-backend
description: Add a backend feature while preserving layering, auth/tenant guarantees, and contract discipline
scope: backend (Go / Node / Python)
inherits: plan-and-implement
composes-rules: [layered-architecture, api-contract-first, json-schema-validation, typed-error-handling, structured-logging, testing-conventions, tenant-isolation, auth-middleware-chain, service-boundary-and-data-ownership, error-envelope]
when-to-invoke: Adding a feature that spans handler + service + repository in a backend service
sources:
  - freightify-web/.cursor/skills/feature-development/SKILL.md
  - fb-rates-go/.cursor/service-knowledge-base/coding-guidelines.md
---
# feature-development-backend

## Purpose
Add a backend feature while preserving layering, auth/tenant guarantees, and contract discipline. Delegates to one of `go-gin-api-authoring`, `node-ts-express-authoring`, or `python-fastapi-authoring` based on the target service.

## Inputs
- Target service(s).
- Feature spec + acceptance criteria.

## Outputs
- Contract update (OpenAPI / AJV / Pydantic / Go struct + tags).
- Controller + service + repository code.
- Tests.
- Task-history entry.

## 7 steps

### 1. Understand
Identify target service, building block, data stores touched. Consult `ownership-matrix.md` to confirm no cross-service DB reach.

### 2. Plan
- Route + middleware chain (`auth-middleware-chain`).
- Contract addition (schema / Pydantic / AJV).
- Service-layer business logic.
- Repository method (`go-base-repository-pattern` / `ts-express-layering` repositories).
- Test plan.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
Dispatch to language-specific authoring skill:
- Go → `go-gin-api-authoring`.
- Node/TS → `node-ts-express-authoring`.
- Python → `python-fastapi-authoring`.

### 6. Self-check
- All rules in `composes-rules` respected for the target stack.
- Tenant isolation preserved if the service is `fb-rates-go` or `fb-iqs`.
- Error envelope includes `code`, `message`, `correlationId`.

### 7. Cleanup / regression
Repo test target passes; structured logs carry `correlationId`.

## Related
- Skills: `go-gin-api-authoring`, `node-ts-express-authoring`, `python-fastapi-authoring`, `event-contract-authoring`, `proxy-integration`.
- Agents: `architecture-agent`, `contract-agent`, `tenant-isolation-agent`.
