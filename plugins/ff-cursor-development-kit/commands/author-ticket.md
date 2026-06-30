---
name: author-ticket
description: Product-team entry point
command: /author-ticket
arguments: "<free-text idea>" [--product <EFP|RMS|ATLAS>] [--project <KEY>] [--bug] [--board <name>] [--reconfigure]
category: primary (product)
on-demand: true
side-effects: writes <product>-ai-brain/task-history/<KEY>.md (## Authoring section); optionally CREATES one JIRA issue (opt-in, confirmed at Gate-P); NEVER deletes, transitions, or reassigns any JIRA entity
---
# /author-ticket "<free-text idea>"

## Purpose
Product-team entry point. Turns a free-text idea into a **complete JIRA ticket in the exact format `/implement` requires**, using the AI-brains to route it to the right building block, repos, project, and board. The mirror-image of `/implement`: it *produces* the ticket the developer later *consumes*.

## Inputs
- A free-text feature/bug idea. `--bug` shapes it as a bug (adds reproduction steps). `--project <KEY>` overrides the resolved project. `--board <name>` pre-selects a board. `--reconfigure` re-runs first-run setup.
- JIRA access via the **Atlassian MCP** if connected in the IDE (preferred — nothing to set); else product-user-local `JIRA_API_TOKEN` / `JIRA_EMAIL` / `JIRA_BASE_URL` (see [auth-and-secrets.md](../jira-integration/auth-and-secrets.md)).
- `jira-integration/jira-projects.json` (product → projects/boards/component map). If missing/incomplete → first-run setup.

## Pipeline
```
[setup — first run only: fetch JIRA projects/boards (via Atlassian MCP or REST), user assigns to products, persist jira-projects.json]
product-intake-agent          (1/7  idea-intake)        restate the idea → product user confirms
  → router-agent (reused)     (2/7  brain-routing)      scope to product → building block → repo(s) + blast radius (within that product's brain ONLY)
  → project/board resolve     (3/7  project-resolved)   product → project (default+override); board ASKED; building-block → component
  → ticket-composer-agent     (4/7  draft-composed)     draft title + problem + acceptance criteria (+ repro if --bug) in implement-intake-format
  → ticket-completeness-agent (5/7  completeness-checked) SAME gate /implement enforces — guarantees /implement-ready
  → [GATE-P — product reviews draft + project/board/component: approve | revise <notes> | reject]
  → jira-writer-agent         (7/7  jira-created)        opt-in: create the issue (or emit copy-paste text); return <KEY>
  → handoff: "Created <KEY> on board <B>. Developer: run /implement <KEY>."
```
Every step banners per [`agent-attribution`](../rules/agent-attribution.md): `### ▸ [N/7] <name>` on line 1, italic action on line 2.

## Product scoping (step 2, before routing)
EFP and RMS share vocabulary (EFP is RMS's rewrite), so generic matching mis-routes (`rate`, `quote`, `charge` exist in both). Routing is therefore **scoped to one product first**, then `router-agent` matches only within that product's brain + `shared-ai-brain` — never across products.
- Resolve the product in order: **`--product` override** → the product user's **remembered default** (per-user local setting) → **ask once** (`EFP / RMS / ATLAS`) and remember.
- This is what stops an EFP idea landing on an RMS building block. ATLAS scopes to `atlas-ai-brain`.

## Project & board resolution (step 3)
1. **Project** = resolved product → `jira-projects.json[product].projects`. One candidate → defaulted; multiple (e.g. EFP's two) → building-block match picks the default, **pre-selected and overridable**.
2. **Board** = **asked** — fetch boards for the chosen project from JIRA, list them (brain may pre-highlight one); product user picks. To make the ticket land on that board, the create step sets the field the board filters on (component/label/sprint) from `component_map`.
3. **Component** = building block → JIRA component (`component_map`).
4. **No building-block match** → service/entity routing → else **Triage**: router shows a best-guess repo shortlist; product user picks; component left blank. Never silently dropped (see `building-block-router`, brain `gaps.md`).

## Gate-P (the one human gate)
Per [`human-approval-gates`](../rules/human-approval-gates.md). The product user sees the resolved project (changeable), board (picked), component, type, and the drafted title/problem/acceptance-criteria, then replies `approve | revise <notes> | reject`. `revise` re-runs `ticket-composer-agent`; `approve` proceeds to create.

## Outputs
- `<product>-ai-brain/task-history/<KEY>.md` with a `## Authoring` section (idea, routing, draft, Gate-P decision, project/board/component) — the SAME file `/implement` later appends to. Pre-key the record lives at `task-history/_drafts/<slug>.md` and is renamed to `<KEY>.md` on create.
- On `approve` + create: one new JIRA issue (Story or Bug) with the resolved fields. On copy-paste mode: the formatted ticket text, no JIRA write.

## Quality gates
- The drafted ticket MUST pass `ticket-completeness` (step 5) before Gate-P — same rule `/implement` refuses without. The composer never fabricates acceptance criteria; gaps are surfaced to the product user to fill (`no-invented-facts`).
- Creating an issue is a JIRA **write** → opt-in, only after Gate-P `approve`, governed by [`jira-write-permissions`](../rules/jira-write-permissions.md) (issue-create allowed under `/author-ticket`; deletes/transitions/reassign forbidden).
- Project is auto-resolved but always overridable; board is always asked — the command never picks a board silently.
- **Component is best-effort**: `jira-writer-agent` verifies the building block's component against the project's *live* JIRA components and sets it only if present; a removed/renamed component is omitted and **never blocks issue creation**.
- Banners per `agent-attribution` at every step.

## Resumability
Re-invoking `/author-ticket` reads `last-phase` from the draft/`<KEY>.md` frontmatter and resumes from the next phase (`idea-intake → brain-routing → project-resolved → draft-composed → completeness-checked → gate-P → jira-created`). See [resumability.md](../jira-integration/resumability.md).

## Related
- Commands: `/implement` (consumes the created ticket), `/triage`, `/route`.
- Agents: `product-intake-agent`, `router-agent`, `ticket-composer-agent`, `ticket-completeness-agent`, `jira-writer-agent`.
- Skills: `ticket-authoring`, `building-block-router`, `task-history-writer`.
- Rules: `implement-intake-format`, `ticket-completeness`, `human-approval-gates`, `jira-write-permissions`, `no-invented-facts`, `agent-attribution`.
- Config: `jira-integration/jira-projects.json`. Flow: `jira-integration/product-flow.md`.
