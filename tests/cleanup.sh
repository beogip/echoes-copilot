#!/usr/bin/env bash
# cleanup.sh - Removes obsolete test files and other artifacts
# Usage: ./cleanup.sh [--dry-run]

set -euo pipefail

# Files to delete (modify as needed)
FILES_TO_DELETE=(
  "tests/unit-tests.sh"
  "tests/integration-tests.sh"
  "tests/installer-tests.sh"
  "tests/edge-case-tests.sh"
  "tests/run-all-tests.sh"
)

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[DRY RUN] Showing files that would be deleted:"
fi

deleted_any=false
for file in "${FILES_TO_DELETE[@]}"; do
  if [[ -f "$file" ]]; then
    if $DRY_RUN; then
      echo "  $file"
    else
      read -p "Delete $file? [y/N]: " confirm
      if [[ "$confirm" =~ ^[yY]$ ]]; then
        rm "$file"
        echo "Deleted: $file"
        deleted_any=true
      else
        echo "Skipped: $file"
      fi
    fi
  else
    echo "Does not exist: $file"
  fi
done

if $DRY_RUN; then
  echo "[DRY RUN] No files deleted."
fi

if ! $DRY_RUN && ! $deleted_any; then
  echo "No files deleted."
fi

exit 0
