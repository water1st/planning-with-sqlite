#!/bin/bash
# Check if all phases in planning.db are complete
# Always exits 0 — uses stdout for status reporting

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_PATH="${1:-planning.db}"

python "$SCRIPT_DIR/check_complete.py" "$DB_PATH"
exit 0
