#!/usr/bin/env bash
# Run SmartTags and keep .dev/db.sqlite linked for DBeaver.
#
# Usage:
#   ./scripts/smartrun.sh
#   ./scripts/smartrun.sh -d "iPhone 17"
#
# Links an existing DB before launch, then watches while Flutter starts
# (fresh install / reinstall when db.sqlite does not exist yet).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

link_db() {
  ./scripts/link-simulator-db.sh 2>/dev/null
}

link_db || true

(
  for _ in $(seq 1 90); do
    if link_db; then
      exit 0
    fi
    sleep 2
  done
) &
WATCHER_PID=$!

cleanup() {
  kill "$WATCHER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

flutter run "$@"
