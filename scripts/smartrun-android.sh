#!/usr/bin/env bash
# Run SmartTags on Android and keep .dev/db.sqlite synced for DBeaver.
#
# Usage:
#   ./scripts/smartrun-android.sh
#   ./scripts/smartrun-android.sh -d emulator-5554
#
# Pulls an existing DB if present, then polls while Flutter starts
# (fresh install / reinstall when db.sqlite does not exist yet).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

link_db() {
  ./scripts/link-android-db.sh 2>/dev/null
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
