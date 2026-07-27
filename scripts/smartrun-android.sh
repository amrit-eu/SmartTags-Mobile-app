#!/usr/bin/env bash
# Run SmartTags on Android and keep .dev/db.sqlite synced for DBeaver.
#
# Usage:
#   ./scripts/smartrun-android.sh
#   ./scripts/smartrun-android.sh -d emulator-5554
#
# Ensures an emulator/device is available (Linux / WSL), pulls an existing DB
# if present, then polls while Flutter starts.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

should_boot_android() {
  local target="$1"
  case "$target" in
    macos|chrome|web|linux|windows|iphone*|iPhone*)
      return 1
      ;;
  esac
  return 0
}

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
  echo ""
}

link_db() {
  ./scripts/link-android-db.sh 2>/dev/null
}

flutter_target="$(resolve_flutter_device "$@")"
if [[ -z "$flutter_target" ]] || should_boot_android "$flutter_target"; then
  ./scripts/boot-android-emulator.sh
fi

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
