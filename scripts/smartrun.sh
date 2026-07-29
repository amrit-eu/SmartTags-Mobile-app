#!/usr/bin/env bash
# Run SmartTags and keep .dev/db.sqlite linked for DBeaver.
#
# Usage:
#   ./scripts/smartrun.sh
#   ./scripts/smartrun.sh -d "iPhone 17"
#
# Boots the iOS Simulator if needed, links an existing DB before launch,
# then keeps re-linking while Flutter runs (reinstall creates a new
# container UUID — exiting after the first link left a broken symlink).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"
LINK_PATH="$ROOT_DIR/.dev/db.sqlite"

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
  # Physical USB/wireless devices are not in simctl — only boot real simulators.
  xcrun simctl list devices available -j 2>/dev/null \
    | python3 -c "
import json, sys
target = sys.argv[1]
data = json.load(sys.stdin)
for devices in data.get('devices', {}).values():
    for d in devices:
        if not d.get('isAvailable'):
            continue
        if d.get('udid') == target or d.get('name') == target:
            sys.exit(0)
sys.exit(1)
" "$target" 2>/dev/null
}

is_ios_simulator_target() {
  should_boot_ios_simulator "$1"
}

current_link_source() {
  if [[ -L "$LINK_PATH" ]]; then
    readlink "$LINK_PATH" || true
  fi
}

# Prints labeled output only when the resolved source path changes.
link_db_if_changed() {
  local label="$1"
  local quiet="${2:-0}"
  local out src
  local err
  err="$(mktemp)"
  if ! out="$(./scripts/link-simulator-db.sh 2>"$err")"; then
    if [[ "$quiet" != "1" ]]; then
      echo ""
      echo "=== $label (skipped) ==="
      if [[ -s "$err" ]]; then
        sed 's/^/  /' "$err"
      else
        echo "  No simulator DB yet — will retry after Flutter starts."
      fi
    fi
    rm -f "$err"
    return 1
  fi
  rm -f "$err"
  src="$(current_link_source)"
  if [[ -z "$src" || ! -e "$src" ]]; then
    return 1
  fi
  if [[ "$src" == "${LAST_DB_SOURCE:-}" ]]; then
    return 0
  fi
  LAST_DB_SOURCE="$src"
  echo ""
  echo "=== $label ==="
  echo "$out"
  return 0
}

flutter_target="$(resolve_flutter_device "$@")"
if should_boot_ios_simulator "$flutter_target"; then
  ./scripts/boot-ios-simulator.sh "$flutter_target"
elif [[ "$flutter_target" != "macos" && "$flutter_target" != "chrome" && "$flutter_target" != "web" ]]; then
  echo "Physical / non-simulator device: $flutter_target"
  echo "Skipping Simulator boot and .dev/db.sqlite link (DBeaver link is simulator-only)."
fi

LAST_DB_SOURCE=""
if is_ios_simulator_target "$flutter_target"; then
  link_db_if_changed "DB link — before Flutter launch" || true

  (
    # Keep watching for the whole flutter run: a cold reinstall replaces the
    # app container after the first successful link, which used to leave
    # .dev/db.sqlite pointing at a deleted path (DBeaver SQLITE_CANTOPEN).
    while true; do
      local_src="$(current_link_source || true)"
      if [[ -n "${local_src:-}" && ! -e "$local_src" ]]; then
        LAST_DB_SOURCE=""
      fi
      # Quiet on repeated misses so flutter run output stays readable.
      link_db_if_changed "DB link — updated (app container ready / reinstalled)" 1 || true
      sleep 3
    done
  ) &
  WATCHER_PID=$!

  cleanup() {
    kill "$WATCHER_PID" 2>/dev/null || true
  }
  trap cleanup EXIT INT TERM
fi

flutter run "$@"
