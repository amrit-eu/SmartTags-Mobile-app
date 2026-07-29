#!/usr/bin/env bash
# Run SmartTags on Android and keep .dev/db.sqlite synced for DBeaver.
#
# Usage:
#   ./scripts/smartrun-android.sh
#   ./scripts/smartrun-android.sh -d emulator-5554
#   ./scripts/smartrun-android.sh -d <physical-serial>   # USB / wireless device
#
# Ensures an emulator/device is available (Linux / WSL / macOS), pulls an
# existing DB before launch, then keeps re-pulling while Flutter runs
# (reinstall / first sync can replace the on-device DB after the first pull).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"
LINK_PATH="$ROOT_DIR/.dev/db.sqlite"
ADB="${ADB:-adb}"

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

# True when we should launch / connect an emulator (no -d, or explicit emulator-*).
should_boot_android_emulator() {
  local target="$1"
  case "$target" in
    ''|emulator-*)
      return 0
      ;;
    macos|chrome|web|linux|windows|iphone*|iPhone*)
      return 1
      ;;
  esac
  # Any other -d value is treated as a physical / already-running device serial.
  return 1
}

wait_for_physical_device() {
  local serial="$1"
  local attempts="${2:-30}"
  local i
  for i in $(seq 1 "$attempts"); do
    if "$ADB" -s "$serial" get-state >/dev/null 2>&1; then
      echo "Physical Android device ready: $serial ($("$ADB" -s "$serial" get-state 2>/dev/null || echo connected))"
      return 0
    fi
    sleep 2
  done
  echo "Physical Android device not ready: $serial" >&2
  echo "Plug it in (USB debugging on), accept the RSA prompt, then retry." >&2
  echo "Check with: adb devices" >&2
  return 1
}

# Fingerprint local copy so we only log when the pulled DB actually changes
# (size + platform count). Works on Linux/WSL (stat -c) and macOS (stat -f).
db_fingerprint() {
  if [[ ! -f "$LINK_PATH" ]]; then
    echo ""
    return 0
  fi
  local size count
  size="$(stat -c%s "$LINK_PATH" 2>/dev/null || stat -f%z "$LINK_PATH" 2>/dev/null || echo 0)"
  count="$(sqlite3 "$LINK_PATH" "SELECT COUNT(*) FROM platforms;" 2>/dev/null || echo "?")"
  echo "${size}:${count}"
}

# Prints labeled output only when the pulled DB fingerprint changes.
link_db_if_changed() {
  local label="$1"
  local quiet="${2:-0}"
  local out fp
  local err
  err="$(mktemp)"
  if ! out="$(./scripts/link-android-db.sh 2>"$err")"; then
    if [[ "$quiet" != "1" ]]; then
      echo ""
      echo "=== $label (skipped) ==="
      if [[ -s "$err" ]]; then
        sed 's/^/  /' "$err"
      else
        echo "  No Android DB yet — will retry after Flutter starts."
      fi
    fi
    rm -f "$err"
    return 1
  fi
  rm -f "$err"
  fp="$(db_fingerprint)"
  if [[ -z "$fp" ]]; then
    return 1
  fi
  if [[ "$fp" == "${LAST_DB_FINGERPRINT:-}" ]]; then
    return 0
  fi
  LAST_DB_FINGERPRINT="$fp"
  echo ""
  echo "=== $label ==="
  echo "$out"
  return 0
}

flutter_target="$(resolve_flutter_device "$@")"

if should_boot_android_emulator "$flutter_target"; then
  ./scripts/boot-android-emulator.sh
  if [[ -n "$flutter_target" ]]; then
    export ANDROID_SERIAL="$flutter_target"
  fi
else
  echo "Physical / non-emulator Android device: $flutter_target"
  echo "Skipping emulator launch — waiting for this device via adb."
  # Pin adb (and DB pull) to this serial when multiple devices are connected.
  export ANDROID_SERIAL="$flutter_target"
  wait_for_physical_device "$flutter_target"
fi

LAST_DB_FINGERPRINT=""
link_db_if_changed "DB link — before Flutter launch" || true

(
  # Keep watching for the whole flutter run: first install / reinstall / Gateway
  # sync can change the on-device DB after the initial pull.
  while true; do
    link_db_if_changed "DB link — updated (app ready / reinstalled / synced)" 1 || true
    sleep 3
  done
) &
WATCHER_PID=$!

cleanup() {
  kill "$WATCHER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

flutter run "$@"
