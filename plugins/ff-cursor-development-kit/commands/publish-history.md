---
name: publish-history
description: Publish completed task-history records to the product brain — **the developer decides when**
command: /publish-history
arguments: [<JIRA-KEY>] [--attach-to-jira]
category: pipeline (publish)
on-demand: true
side-effects: in <product>-ai-brain ONLY — creates a branch off development, commits task-history .md file(s), pushes, and raises ONE merge request into development. NEVER merges. NEVER touches service repos or the developer's code.
---
# /publish-history [<JIRA-KEY>]

## Purpose
Publish completed task-history records to the product brain — **the developer decides when**. Batches all pending records (frontmatter `published: false`) into **one** branch + **one** MR into `development`. A separate agent validates and merges the MR. The `/implement` pipeline never pushes the record itself; Step 13 only **reminds** (see [pipeline.md](../jira-integration/pipeline.md)).

## Inputs
- Optional `<JIRA-KEY>` — publish just that record. Omitted → publish **all** pending records, batched.
- `--attach-to-jira` (optional) — also attach each published `.md` to its JIRA ticket.
- `<product>-ai-brain` cloned with a `development` branch + push access. Product auto-detected from the workspace.

## "Pending" = `published: false`
A record becomes pending when its run reaches `gate-2` (`/implement` writes `<KEY>.md` with `published: false`). Only this command flips it to `true`.

## Steps
```
1. Resolve product → <product>-ai-brain. Collect pending records:
     no arg  → every task-history/*.md with `published: false`
     <KEY>   → just task-history/<KEY>.md (must be published:false)
   None pending → "Nothing to publish." and stop.
2. Preflight the brain repo: clean tree; git fetch; git checkout development; git pull --ff-only origin development.
3. Create the MR branch OFF development:
     batch (no arg) → ai/task-history-<user>-<readable-ts>
                      e.g. ai/task-history-ashish-zanwar-30th-jun-2026-10.15-AM
     single (<KEY>) → ai/<KEY>-<slug>            e.g. ai/EFP-1234-frlc-category
   <user> = slug of `git config user.email` local-part.
   <readable-ts> = <day><ord>-<mon-lc>-<year>-<h>.<mm>-<AM|PM>  (12-hour; "." between H and MM; AM/PM upper).
   If that exact branch already exists (two runs in the same minute) → append "-2".
4. For each pending record, set frontmatter (via task-history-writer, phase `publish`):
     published: true · published-by: <git email> · published-at: <readable> · publish-branch: <branch>
5. git add the record(s); commit AUTHORED BY the developer's git identity (name <email>) so blame shows who:
     "task-history: publish <KEY[,KEY...]>"
6. Push + raise ONE MR via push-options:
     git push -u origin <branch> \
       -o merge_request.create \
       -o merge_request.target=development \
       -o merge_request.title="task-history: <KEY[,...]>" \
       -o merge_request.description="Published by <name> <email>"
7. Write `publish-mr: <url>` back to each record (best-effort); report the MR URL. Do NOT merge.
```

## Identity captured (who pushed)
Four independent places survive the auto-merge: the **branch name** (`<user>` + timestamp), the **commit author**, the **GitLab MR author** (the pusher), and the record's **`published-by` / `published-at`** frontmatter.

## Constraints
- **Brain repo + task-history `.md` only.** Never runs git in a service repo; never touches the developer's code.
- **Never merges.** Raises the MR into `development` and stops — a separate agent merges. (Extends `/implement`'s no-auto-merge directive.)
- **One branch + one MR per invocation** (batch), unless a single `<KEY>` is given.
- **Idempotent.** A record already `published: true` is skipped; nothing pending → no-op.
- If push/MR fails, revert the record's `published` back to `false` (stays pending) and report the error — never leave a half-published state.

## Related
- Commands: `/implement`, `/bugfix` (Step 13 reminds; this command publishes).
- Skills: `task-history-writer` (phase `publish`).
- Docs: `jira-integration/audit-trail.md` (the `published` flags), `jira-integration/pipeline.md` (Step 13 reminder), base-branch directive (no auto-merge).
