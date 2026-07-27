#!/usr/bin/env bash
# Boots the iOS Simulator when it is shutdown (macOS dev only).
#
# Usage:
#   ./scripts/boot-ios-simulator.sh
#   ./scripts/boot-ios-simulator.sh "iPhone 17"
#
# Optional env: SIMULATOR_NAME, SIMULATOR_DEVICE_ID

set -euo pipefail

TARGET="${1:-${SIMULATOR_DEVICE_ID:-${SIMULATOR_NAME:-iPhone 17}}}"

case "$TARGET" in
  macos|chrome|web|linux|windows|emulator-*)
    exit 0
    ;;
esac

read -r device_id state <<< "$(xcrun simctl list devices available -j \
  | python3 -c "
import json, sys
target = sys.argv[1]
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if not d.get('isAvailable'):
            continue
        if d['udid'] == target or d['name'] == target:
            print(d['udid'], d.get('state', 'Shutdown'))
            sys.exit(0)
sys.exit(1)
" "$TARGET" 2>/dev/null)" || {
  echo "iOS simulator not found: $TARGET" >&2
  exit 1
}

if [[ "$state" != "Booted" ]]; then
  xcrun simctl boot "$device_id"
fi

open -a Simulator

echo "Simulator ready: $TARGET ($device_id)"
