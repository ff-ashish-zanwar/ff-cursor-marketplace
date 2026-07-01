#!/usr/bin/env bash
# gen-team-readme.sh — drop the static workspace README at a team workspace root.
#
# The README is PRODUCT-AGNOSTIC on purpose: it's identical for every workspace and its only job is to tell the
# user to run /start. /start then detects the product and generates the product-specific getting-started.md.
# So this script just copies the canonical README source into place — no product substitution.
#
# Usage:
#   bash scripts/gen-team-readme.sh [<dest-file>]
#
#   <dest-file>  Optional. Defaults to ./README.md in the current directory
#                (run it from the team's workspace root).
#
# (A product name may be passed as the first arg for backward compatibility; it is ignored — the README is agnostic.)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/team-readme.template.md"

# Back-compat: if the first arg looks like a product, ignore it and shift so $1 can still be the dest file.
case "${1:-}" in
  EFP|RMS|ATLAS) shift ;;
esac
DEST="${1:-README.md}"

[ -f "$SRC" ] || { echo "ERROR: README source not found at $SRC" >&2; exit 1; }
cp "$SRC" "$DEST"
echo "Wrote $DEST (product-agnostic — run /start inside the workspace for the product-specific guide)"
