#!/usr/bin/env bash
#
# sync-repos.sh — pull the latest base branch on every product repo in one shot.
#
# Supports BOTH workspace layouts:
#   • FLAT (canonical since 2026-07-09): repos cloned directly at the workspace
#     root (Freightify-AI-<PRODUCT>-Workspace/<repo>/ …), next to config/ and
#     getting-started.md.
#   • NESTED (legacy/admin): repos under <Product>-Repos/ folders.
#
# For each repo found:
#   1. Skip AI brains (names matching *ai-brain* or *ai-knowledge-base*) and
#      engine/tooling repos (freightify-ai-workflow, ff-cursor-marketplace).
#   2. If the only working-tree change is a stray .DS_Store, discard it.
#   3. Pick the base branch:
#        a. If the repo is listed in config/git-branch.json → use that branch.
#        b. Otherwise fall back to the ordered `fallback_branches` from that file
#           (default: development → dev → IMD-Development → imd-dev) and use the
#           FIRST that exists on origin. If none exist, skip the repo.
#   4. Checkout that branch and `git pull --ff-only`.
#   5. On any other problem (dirty tree, conflict, auth, detached, mapped branch
#      missing, etc.) the repo is SKIPPED — never force-reset, never stash, never
#      lose work.
# A per-repo status report (repo · branch · SUCCESS/FAILURE) is printed at the end,
# so every repo is accounted for.
#
# CONFIG: <workspace-root>/config/git-branch.json (repo→branch map + fallback_branches).
#   Read with jq if present, else python3, else a grep fallback. If the file is
#   absent, every repo just uses the default fallback sequence.
#
# Usage:
#   bash sync-repos.sh                 # auto-detect the workspace root
#   bash sync-repos.sh --workspace DIR # point at a specific workspace root
#   FREIGHTIFY_WORKSPACE=DIR bash sync-repos.sh
#   bash sync-repos.sh --help
#
# Exit code is 0 even when some repos are skipped; the summary tells the story.

set -uo pipefail

# Never hang on a credential or host-key prompt — fail fast and skip instead.
export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=20}"

# ---- colours (disabled when not a TTY) --------------------------------------
if [ -t 1 ]; then
  B=$'\033[1m'; DIM=$'\033[2m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; C=$'\033[36m'; X=$'\033[0m'
else
  B=""; DIM=""; G=""; Y=""; R=""; C=""; X=""
fi

# ---- args -------------------------------------------------------------------
WORKSPACE="${FREIGHTIFY_WORKSPACE:-}"
DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) WORKSPACE="${2:-}"; shift 2 ;;
    --workspace=*) WORKSPACE="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,37p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1 (try --help)"; exit 2 ;;
  esac
done

# ---- locate the workspace root ------------------------------------------------
# A workspace root is EITHER a dir holding *-Repos folders (nested/legacy layout)
# OR a flat workspace root: has config/git-branch.json or a *-ai-brain clone.
has_repos_folders() { compgen -G "$1/*-Repos" >/dev/null 2>&1; }
is_flat_workspace() { [ -f "$1/config/git-branch.json" ] || compgen -G "$1/*-ai-brain" >/dev/null 2>&1; }
is_workspace_root() { has_repos_folders "$1" || is_flat_workspace "$1"; }

find_workspace() {
  local d
  # 1) explicit override
  if [ -n "$WORKSPACE" ]; then echo "$WORKSPACE"; return; fi
  # 2) walk up from the current working directory
  d="$PWD"
  while [ "$d" != "/" ]; do
    is_workspace_root "$d" && { echo "$d"; return; }
    d="$(dirname "$d")"
  done
  # 3) walk up from this script's own location
  d="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  while [ "$d" != "/" ]; do
    is_workspace_root "$d" && { echo "$d"; return; }
    d="$(dirname "$d")"
  done
  return 1
}

WS="$(find_workspace)" || {
  echo "${R}✗ Could not find a workspace root (no *-Repos folder, config/git-branch.json, or *-ai-brain).${X}"
  echo "  Run this from inside your Freightify workspace, or pass --workspace <path>."
  exit 1
}
echo "${B}Workspace:${X} $WS"

# ---- config: repo → base branch map -----------------------------------------
CONFIG="$WS/config/git-branch.json"
DEFAULT_FALLBACK=(development dev IMD-Development imd-dev)

# Look up the mapped branch for a repo. Echoes the branch, or nothing if unmapped.
# Prefers jq, then python3, then a grep fallback — so no hard dependency on jq.
lookup_branch() {
  local repo="$1"
  [ -f "$CONFIG" ] || return 0
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg r "$repo" '.repositories[$r] // empty' "$CONFIG" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys
try:
    d=json.load(open(sys.argv[1]))
    print(d.get("repositories",{}).get(sys.argv[2],""))
except Exception:
    pass' "$CONFIG" "$repo" 2>/dev/null
  else
    # grep fallback: match  "repo": "branch"
    grep -Eo "\"$repo\"[[:space:]]*:[[:space:]]*\"[^\"]+\"" "$CONFIG" 2>/dev/null \
      | head -1 | sed -E 's/.*:[[:space:]]*"([^"]+)"/\1/'
  fi
}

# Load the fallback sequence from config (else the built-in default).
load_fallback() {
  local list=""
  if [ -f "$CONFIG" ]; then
    if command -v jq >/dev/null 2>&1; then
      list="$(jq -r '.fallback_branches[]?' "$CONFIG" 2>/dev/null)"
    elif command -v python3 >/dev/null 2>&1; then
      list="$(python3 -c 'import json,sys
try:
    d=json.load(open(sys.argv[1]))
    print("\n".join(d.get("fallback_branches",[])))
except Exception:
    pass' "$CONFIG" 2>/dev/null)"
    fi
  fi
  if [ -n "$list" ]; then printf '%s\n' "$list"; else printf '%s\n' "${DEFAULT_FALLBACK[@]}"; fi
}
FALLBACK_BRANCHES=(); while IFS= read -r b; do [ -n "$b" ] && FALLBACK_BRANCHES+=("$b"); done < <(load_fallback)

if [ -f "$CONFIG" ]; then
  echo "${B}Config:${X}    $CONFIG  ${DIM}(fallback: ${FALLBACK_BRANCHES[*]})${X}"
else
  echo "${Y}Config:    none found at $CONFIG — using fallback: ${FALLBACK_BRANCHES[*]}${X}"
fi
echo

# ---- result accumulators ----------------------------------------------------
PULLED=()   # "group|name|branch|note"
SKIPPED=()  # "group|name|reason"
EXCLUDED=() # "group|name"

is_brain() { case "$1" in *ai-brain*|*ai-knowledge-base*) return 0;; *) return 1;; esac; }
is_tooling() { case "$1" in freightify-ai-workflow|ff-cursor-marketplace|ai-platform) return 0;; *) return 1;; esac; }

process_repo() {
  local dir="$1" group="$2" name; name="$(basename "$dir")"
  cd "$dir" 2>/dev/null || { SKIPPED+=("$group|$name|-|cannot enter directory"); return; }

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    SKIPPED+=("$group|$name|-|not a git repo"); return
  fi

  # --- dirty-tree handling: discard a lone .DS_Store, otherwise skip ----------
  local note="" porcelain non_ds
  porcelain="$(git status --porcelain 2>/dev/null)"
  if [ -n "$porcelain" ]; then
    non_ds="$(printf '%s\n' "$porcelain" | grep -v '\.DS_Store$')"
    if [ -z "$non_ds" ]; then
      git restore -- '.DS_Store' >/dev/null 2>&1
      printf '%s\n' "$porcelain" | awk '{print $NF}' | while IFS= read -r f; do
        [ "$(basename "$f")" = ".DS_Store" ] && rm -f "$f" 2>/dev/null
      done
      if [ -n "$(git status --porcelain 2>/dev/null | grep -v '\.DS_Store$')" ]; then
        SKIPPED+=("$group|$name|-|dirty tree after discarding .DS_Store"); return
      fi
      note=".DS_Store discarded"
    else
      SKIPPED+=("$group|$name|-|uncommitted changes (not just .DS_Store)"); return
    fi
  fi

  # --- choose the base branch: config mapping first, else fallback sequence ----
  remote_has() { git ls-remote --heads origin "$1" 2>/dev/null | grep -q "refs/heads/$1$"; }
  local branch="" mapped; mapped="$(lookup_branch "$name")"
  if [ -n "$mapped" ]; then
    # Repo is pinned in config/git-branch.json — that branch must exist on origin.
    if remote_has "$mapped"; then
      branch="$mapped"
    else
      SKIPPED+=("$group|$name|$mapped|mapped branch '$mapped' not found on origin"); return
    fi
  else
    # Not pinned — walk the fallback sequence, first that exists on origin wins.
    local fb
    for fb in "${FALLBACK_BRANCHES[@]}"; do
      if remote_has "$fb"; then branch="$fb"; break; fi
    done
    [ -z "$branch" ] && { SKIPPED+=("$group|$name|-|none of [${FALLBACK_BRANCHES[*]}] exist on origin"); return; }
  fi

  # --- dry-run: report the chosen branch without touching the repo ------------
  if [ "$DRY_RUN" = "1" ]; then
    local src; [ -n "$mapped" ] && src="config" || src="fallback"
    local cur0; cur0="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    PULLED+=("$group|$name|$branch|would checkout ($src) + pull${note:+ ($note)}${cur0:+; now on $cur0}")
    printf '  %s•%s %-28s %s%s%s  %swould checkout+pull (%s)%s\n' "$C" "$X" "$name" "$C" "$branch" "$X" "$DIM" "$src" "$X"
    return
  fi

  # --- checkout (record a switch for transparency) ----------------------------
  local cur; cur="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [ "$cur" != "$branch" ]; then
    if ! git checkout "$branch" >/dev/null 2>&1; then
      SKIPPED+=("$group|$name|$branch|cannot checkout $branch (was on $cur)"); return
    fi
    note="${note:+$note; }switched from $cur"
  fi

  # --- pull -------------------------------------------------------------------
  local out summary
  if out="$(git pull --ff-only origin "$branch" 2>&1)"; then
    summary="$(printf '%s\n' "$out" | grep -Eo 'Already up to date|Fast-forward|Updating [0-9a-f]+\.\.[0-9a-f]+' | head -1)"
    [ -z "$summary" ] && summary="updated"
    PULLED+=("$group|$name|$branch|${summary}${note:+ ($note)}")
    printf '  %s✓%s %-28s %s%s%s  %s%s%s\n' "$G" "$X" "$name" "$C" "$branch" "$X" "$DIM" "$summary" "$X"
  else
    summary="$(printf '%s\n' "$out" | tail -1)"
    SKIPPED+=("$group|$name|$branch|pull failed: $summary")
    printf '  %s↷%s %-28s %s%s%s  %sskip — pull failed%s\n' "$Y" "$X" "$name" "$C" "$branch" "$X" "$Y" "$X"
  fi
}

# ---- main loop --------------------------------------------------------------
shopt -s nullglob

# Process one flat workspace dir: every top-level git repo, minus brains/tooling.
process_flat_workspace() {
  local root="$1" group="$2" d name
  echo "${B}=== $group (flat layout) ===${X}"
  for d in "$root"/*/; do
    d="${d%/}"; name="$(basename "$d")"
    if is_brain "$name"; then EXCLUDED+=("$group|$name"); continue; fi
    if is_tooling "$name"; then EXCLUDED+=("$group|$name"); continue; fi
    [ -e "$d/.git" ] || continue   # silently skip non-repo dirs (config/, _scratch/, …)
    process_repo "$d" "$group"
  done
  echo
}

repos_groups=( "$WS"/*-Repos )
ws_children=( "$WS"/Freightify-AI-*-Workspace )
if [ ${#repos_groups[@]} -gt 0 ]; then
  # V1 (nested) layout: repos under <Product>-Repos/ folders
  for repos_dir in "${repos_groups[@]}"; do
    group="$(basename "$repos_dir")"
    echo "${B}=== $group ===${X}"
    for d in "$repos_dir"/*/; do
      d="${d%/}"; name="$(basename "$d")"
      if is_brain "$name"; then EXCLUDED+=("$group|$name"); continue; fi
      if is_tooling "$name"; then EXCLUDED+=("$group|$name"); continue; fi
      process_repo "$d" "$group"
    done
    echo
  done
elif [ ${#ws_children[@]} -gt 0 ]; then
  # V2 admin container: the root holds per-product flat workspaces
  for child in "${ws_children[@]}"; do
    process_flat_workspace "$child" "$(basename "$child")"
  done
else
  # V2 (flat) layout: repos directly at the workspace root
  process_flat_workspace "$WS" "$(basename "$WS")"
fi

# ---- summary ----------------------------------------------------------------
echo "${B}──────────────────────────── SUMMARY ────────────────────────────${X}"
echo "${G}Pulled:${X} ${#PULLED[@]}    ${Y}Skipped:${X} ${#SKIPPED[@]}    ${DIM}Excluded (AI brains):${X} ${#EXCLUDED[@]}"
echo

if [ ${#PULLED[@]} -gt 0 ]; then
  echo "${G}${B}✓ SUCCESS${X}"
  printf '  %-11s %-28s %-16s %s\n' "PRODUCT" "REPO" "BRANCH" "RESULT"
  for r in "${PULLED[@]}"; do IFS='|' read -r g n b s <<<"$r"
    printf '  %-11s %-28s %s%-16s%s %s\n' "$g" "$n" "$C" "$b" "$X" "$s"
  done
  echo
fi
if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "${Y}${B}✗ FAILURE / SKIPPED${X}"
  printf '  %-11s %-28s %-16s %s\n' "PRODUCT" "REPO" "BRANCH" "REASON"
  for r in "${SKIPPED[@]}"; do IFS='|' read -r g n b reason <<<"$r"
    printf '  %-11s %-28s %-16s %s\n' "$g" "$n" "$b" "$reason"
  done
  echo
fi
if [ ${#EXCLUDED[@]} -gt 0 ]; then
  echo "${DIM}${B}🚫 Excluded — AI brains (never pulled by this tool)${X}"
  for r in "${EXCLUDED[@]}"; do IFS='|' read -r g n <<<"$r"
    printf '  %s%-11s %s%s\n' "$DIM" "$g" "$n" "$X"
  done
fi
