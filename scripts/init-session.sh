#!/bin/bash
# Initialize planning database for a new session
# Usage: ./init-session.sh [project-name]

set -e

PROJECT_NAME="${1:-project}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_PATH="${PWD}/planning.db"

echo "Initializing planning database for: $PROJECT_NAME"

if [ ! -f "$DB_PATH" ]; then
    python "$SCRIPT_DIR/init_db.py" "$DB_PATH"
else
    echo "planning.db already exists, skipping initialization"
fi

echo ""
echo "Planning database initialized at: $DB_PATH"
