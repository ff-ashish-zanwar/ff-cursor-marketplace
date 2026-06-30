#!/usr/bin/env bash
#
# sync-repos.sh — pull the latest on every product repo in one shot.
#
# For each repo under every <Product>-Repos/ folder in the workspace:
#   1. Skip AI brains (names matching *ai-brain* or *ai-knowledge-base*).
#   2. If the only working-tree change is a stray .DS_Store, discard it.
#   3. Pick the integration branch: prefer `development`, fall back to `dev`.
#      If neither exists on origin, skip the repo.
#   4. Checkout that branch and `git pull`.
#   5. On any other problem (dirty tree, conflict, auth, detached, etc.) the
#      repo is SKIPPED — never force-reset, never stash, never lose work.
# A summary table is printed at the end.
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
while [ $# -gt 0 ]; do
  case "$1" in
    --workspace) WORKSPACE="${2:-}"; shift 2 ;;
    --workspace=*) WORKSPACE="${1#*=}"; shift ;;
    -h|--help)
      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1 (try --help)"; exit 2 ;;
  esac
done

# ---- locate the workspace root (the dir that holds the *-Repos folders) ------
has_repos_folders() { compgen -G "$1/*-Repos" >/dev/null 2>&1; }

find_workspace() {
  local d
  # 1) explicit override
  if [ -n "$WORKSPACE" ]; then echo "$WORKSPACE"; return; fi
  # 2) walk up from the current working directory
  d="$PWD"
  while [ "$d" != "/" ]; do
    has_repos_folders "$d" && { echo "$d"; return; }
    d="$(dirname "$d")"
  done
  # 3) walk up from this script's own location
  d="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  while [ "$d" != "/" ]; do
    has_repos_folders "$d" && { echo "$d"; return; }
    d="$(dirname "$d")"
  done
  return 1
}

WS="$(find_workspace)" || {
  echo "${R}✗ Could not find any *-Repos folder.${X}"
  echo "  Run this from inside your Freightify workspace, or pass --workspace <path>."
  exit 1
}
echo "${B}Workspace:${X} $WS"
echo

# ---- result accumulators ----------------------------------------------------
PULLED=()   # "group|name|branch|note"
SKIPPED=()  # "group|name|reason"
EXCLUDED=() # "group|name"

is_brain() { case "$1" in *ai-brain*|*ai-knowledge-base*) return 0;; *) return 1;; esac; }

process_repo() {
  local dir="$1" group="$2" name; name="$(basename "$dir")"
  cd "$dir" 2>/dev/null || { SKIPPED+=("$group|$name|cannot enter directory"); return; }

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    SKIPPED+=("$group|$name|not a git repo"); return
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
        SKIPPED+=("$group|$name|dirty tree after discarding .DS_Store"); return
      fi
      note=".DS_Store discarded"
    else
      SKIPPED+=("$group|$name|uncommitted changes (not just .DS_Store)"); return
    fi
  fi

  # --- choose integration branch: development first, then dev -----------------
  local branch=""
  if git ls-remote --heads origin development 2>/dev/null | grep -q 'refs/heads/development$'; then
    branch="development"
  elif git ls-remote --heads origin dev 2>/dev/null | grep -q 'refs/heads/dev$'; then
    branch="dev"
  fi
  [ -z "$branch" ] && { SKIPPED+=("$group|$name|no development/dev branch"); return; }

  # --- checkout (record a switch for transparency) ----------------------------
  local cur; cur="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [ "$cur" != "$branch" ]; then
    if ! git checkout "$branch" >/dev/null 2>&1; then
      SKIPPED+=("$group|$name|cannot checkout $branch (was on $cur)"); return
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
    SKIPPED+=("$group|$name|pull failed: $summary")
    printf '  %s↷%s %-28s %sskip — pull failed%s\n' "$Y" "$X" "$name" "$Y" "$X"
  fi
}

# ---- main loop --------------------------------------------------------------
shopt -s nullglob
for repos_dir in "$WS"/*-Repos; do
  group="$(basename "$repos_dir")"
  echo "${B}=== $group ===${X}"
  for d in "$repos_dir"/*/; do
    d="${d%/}"; name="$(basename "$d")"
    if is_brain "$name"; then EXCLUDED+=("$group|$name"); continue; fi
    process_repo "$d" "$group"
  done
  echo
done

# ---- summary ----------------------------------------------------------------
echo "${B}──────────────────────────── SUMMARY ────────────────────────────${X}"
echo "${G}Pulled:${X} ${#PULLED[@]}    ${Y}Skipped:${X} ${#SKIPPED[@]}    ${DIM}Excluded (AI brains):${X} ${#EXCLUDED[@]}"
echo

if [ ${#PULLED[@]} -gt 0 ]; then
  echo "${G}${B}✓ Pulled${X}"
  for r in "${PULLED[@]}"; do IFS='|' read -r g n b s <<<"$r"
    printf '  %-11s %-28s %-12s %s\n' "$g" "$n" "$b" "$s"
  done
  echo
fi
if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "${Y}${B}↷ Skipped${X}"
  for r in "${SKIPPED[@]}"; do IFS='|' read -r g n reason <<<"$r"
    printf '  %-11s %-28s %s\n' "$g" "$n" "$reason"
  done
  echo
fi
if [ ${#EXCLUDED[@]} -gt 0 ]; then
  echo "${DIM}${B}🚫 Excluded — AI brains (never pulled by this tool)${X}"
  for r in "${EXCLUDED[@]}"; do IFS='|' read -r g n <<<"$r"
    printf '  %s%-11s %s%s\n' "$DIM" "$g" "$n" "$X"
  done
fi
