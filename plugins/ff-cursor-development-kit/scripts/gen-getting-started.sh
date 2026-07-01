#!/usr/bin/env bash
# gen-getting-started.sh — generate a product-specific root getting-started.md for a team workspace.
#
# getting-started.md is the written onboarding walkthrough that sits at the root of each per-product
# workspace (Freightify-AI-<PRODUCT>-Workspace/). Its main call-to-action is "run /start" — the live,
# product-aware orientation command. This script renders the template for one product.
#
# Usage:
#   bash scripts/gen-getting-started.sh <EFP|RMS|ATLAS> [<dest-file>]
#
#   <dest-file>  Optional. Defaults to ./getting-started.md in the current directory
#                (run it from the team's workspace root).
#
# It substitutes {{PRODUCT}} (upper) and {{product}} (lower) in getting-started.template.md.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPL="$SCRIPT_DIR/getting-started.template.md"

PROD="${1:-}"
DEST="${2:-getting-started.md}"
case "$PROD" in
  EFP|RMS|ATLAS) ;;
  *) echo "usage: $0 <EFP|RMS|ATLAS> [dest-file]" >&2; exit 1 ;;
esac
[ -f "$TMPL" ] || { echo "ERROR: template not found at $TMPL" >&2; exit 1; }

prod_lower="$(printf '%s' "$PROD" | tr 'A-Z' 'a-z')"
sed -e "s/{{PRODUCT}}/$PROD/g" -e "s/{{product}}/$prod_lower/g" "$TMPL" > "$DEST"
echo "Wrote $DEST for $PROD"
