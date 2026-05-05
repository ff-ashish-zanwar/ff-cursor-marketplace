---
name: proxy-integration
description: Add a new downstream HTTP integration via `BaseProxy` subclass (Go or TS)
scope: backend services
inherits: plan-and-implement
composes-rules: [go-proxy-pattern, ts-express-layering, layered-architecture, secrets-management, structured-logging, typed-error-handling, error-envelope, auth-provider-per-service-family]
when-to-invoke: Adding a new outbound HTTP integration in a Go or Node service
sources:
  - fb-rates-go/.cursor/service-knowledge-base/core-components.md
  - admin-backend/.cursor/service-knowledge-base/core-components.md
---
# proxy-integration

## Purpose
Add a new downstream HTTP integration via `BaseProxy` subclass (Go or TS). Wires API-key / JWT / bearer correctly and keeps error/log handling centralised.

## 7 steps

### 1. Understand
Identify the downstream service, its auth style, and the caller's service family. Confirm the correct secret location (SSM for AWS services; Parameter Manager for GCP).

### 2. Plan
- New proxy type (`<Target>Proxy`) extending `BaseProxy`.
- Config struct: base URL, timeouts, retry, auth style.
- Methods: one per downstream endpoint with typed request / response.
- Error mapping: downstream errors translate to the caller's typed error family.

### 3. Propose

### 4. Pause for human approval

### 5. Implement
- Secret load at bootstrap.
- Proxy registered in the service's DI / wiring module.
- Callers use the proxy, never `http.Client.Do`.

### 6. Self-check
- No credentials printed in logs; headers redacted in any diagnostic output.
- Retry + timeout are explicit; no infinite retry loops.
- Context propagation mandatory; cancellation honoured.

### 7. Cleanup / regression
Unit tests against `httptest.Server` (Go) or `nock` (TS). Integration smoke test on staging.

## Related
- Skills: `go-gin-api-authoring`, `node-ts-express-authoring`, `event-contract-authoring`.
- Agents: `architecture-agent`, `security-agent`, `contract-agent`.
