---
name: go-gin-api-authoring
description: Author a new Gin route end-to-end: contract → route → middleware → controller → service → repository → proxy → tests
scope: fb-rates-go, fb-iqs, quote-ai-backend, fy-iam-go, skipperroutes
inherits: plan-and-implement
composes-rules: [layered-architecture, go-proxy-pattern, go-base-repository-pattern, go-vendor-deps, auth-middleware-chain, tenant-isolation, api-contract-first, json-schema-validation, typed-error-handling, error-envelope, structured-logging, testing-conventions]
when-to-invoke: Adding an HTTP endpoint to a Go / Gin service
sources:
  - fb-rates-go/.cursor/service-knowledge-base/coding-guidelines.md
  - fb-iqs/.cursor/architecture.md
  - quote-ai-backend/.cursor/architecture.md
---
# go-gin-api-authoring

## Purpose
Author a new Gin route end-to-end: contract → route → middleware → controller → service → repository → proxy → tests.

## 7 steps

### 1. Understand
Target service + building block + data stores. Consult `ai-brain/service-cards/<service>.md` and `ownership-matrix.md`.

### 2. Plan
- Contract: Go struct with `json:` + `binding:` tags; optionally an OpenAPI fragment.
- Route: registered in the service's route file; middleware chain applied (`Token → Tenant → User → Company → Role → Efp` where applicable).
- Controller: parse + validate + delegate.
- Service: business logic; returns typed errors.
- Repository: extends `BaseRepository[T]`; tenant-aware Mongo handle for fb-rates-go / fb-iqs.
- Proxy: new downstream via `BaseProxy` subclass (if needed).
- Tests: controller test, service test, repository integration test (httptest + mongo test container where appropriate).

### 3. Propose

### 4. Pause for human approval

### 5. Implement
Order: struct → repo method → service method → controller → route registration → tests.

### 6. Self-check
- Middleware chain correct.
- Tenant handle resolved through `TenantMongoManager` in fb-rates-go / fb-iqs.
- Error path returns envelope with `code`, `message`, `correlationId`.
- Zap log lines carry `correlationId` + `vendorId`.
- `go mod tidy && go mod vendor` run; `vendor/` committed.

### 7. Cleanup / regression
`go test ./...`; `go build -mod=vendor ./...`; review the diff against `pr-review`.

## Related
- Skills: `mongo-schema-change`, `event-contract-authoring`, `proxy-integration`.
- Agents: `architecture-agent`, `contract-agent`, `tenant-isolation-agent`.
