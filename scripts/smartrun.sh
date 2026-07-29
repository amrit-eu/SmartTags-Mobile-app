#!/usr/bin/env bash
# Run SmartTags and keep .dev/db.sqlite linked for DBeaver.
#
# Usage:
#   ./scripts/smartrun.sh
#   ./scripts/smartrun.sh -d "iPhone 17"
#
# Boots the iOS Simulator if needed, links an existing DB before launch,
# then watches while Flutter starts (fresh install / reinstall).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

resolve_flutter_device() {
  local args=("$@")
  local i=0
  while [[ $i -lt ${#args[@]} ]]; do
    if [[ "${args[$i]}" == "-d" && $((i + 1)) -lt ${#args[@]} ]]; then
      echo "${args[$((i + 1))]}"
      return
    fi
    i=$((i + 1))
  done
  echo "${SIMULATOR_NAME:-iPhone 17}"
}

should_boot_ios_simulator() {
  local target="$1"
  case "$target" in
    macos|chrome|web|linux|windows|emulator-*)
      return 1
      ;;
  esac
  return 0
}

link_db() {
  local label="$1"
  local out
  if out="$(./scripts/link-simulator-db.sh 2>/dev/null)"; then
    echo ""
    echo "=== $label ==="
    echo "$out"
    return 0
  fi
  return 1
}

flutter_target="$(resolve_flutter_device "$@")"
if should_boot_ios_simulator "$flutter_target"; then
  ./scripts/boot-ios-simulator.sh "$flutter_target"
fi

link_db "DB link — before Flutter launch" || true

(
  for _ in $(seq 1 90); do
    if link_db "DB link — after Flutter launch / app container ready"; then
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
