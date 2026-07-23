#!/usr/bin/env bash
# Links the iOS Simulator SmartTags SQLite DB to a stable path for DBeaver / sqlite3.
#
# Usage (from repo root):
#   ./scripts/link-simulator-db.sh
#
# Optional env vars:
#   SIMULATOR_DEVICE_ID  — e.g. DC85A60A-C02B-4992-833B-C1D90B8A0EE3 (iPhone 17)
#   SIMULATOR_NAME       — e.g. "iPhone 17" (used if device id not set)
#
# After running, open in DBeaver:
#   <repo>/.dev/db.sqlite
#
# Re-run after deleting/reinstalling the app on the simulator.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LINK_PATH="$ROOT_DIR/.dev/db.sqlite"
SIMULATOR_ROOT="$HOME/Library/Developer/CoreSimulator/Devices"

resolve_device_id() {
  if [[ -n "${SIMULATOR_DEVICE_ID:-}" ]]; then
    echo "$SIMULATOR_DEVICE_ID"
    return
  fi

  local name="${SIMULATOR_NAME:-iPhone 17}"
  xcrun simctl list devices available -j \
    | python3 -c "
import json, sys
name = sys.argv[1]
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d.get('name') == name and d.get('isAvailable'):
            print(d['udid'])
            sys.exit(0)
sys.exit(1)
" "$name"
}

device_id="$(resolve_device_id)"
search_root="$SIMULATOR_ROOT/$device_id/data/Containers/Data/Application"

if [[ ! -d "$search_root" ]]; then
  echo "No app containers found for simulator $device_id." >&2
  echo "Install and run SmartTags on the simulator first." >&2
  exit 1
fi

db_path="$(find "$search_root" -name db.sqlite 2>/dev/null | head -1)"

if [[ -z "$db_path" ]]; then
  echo "No db.sqlite found under $search_root" >&2
  echo "Run the app once so Drift creates the database." >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/.dev"
ln -sf "$db_path" "$LINK_PATH"

count="$(sqlite3 "$LINK_PATH" "SELECT COUNT(*) FROM platforms;" 2>/dev/null || echo "?")"

echo "Linked simulator DB → $LINK_PATH"
echo "Source: $db_path"
echo "Platforms: $count"
echo ""
echo "DBeaver: New Connection → SQLite → Path:"
echo "  $LINK_PATH"
