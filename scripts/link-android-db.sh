#!/usr/bin/env bash
# Pulls the Android emulator/device SQLite DB to a stable path for DBeaver / sqlite3.
#
# Usage (from repo root):
#   ./scripts/link-android-db.sh
#
# Works on Linux, macOS (Android emulator), and Windows WSL when adb can see a device.
#
# Optional env vars:
#   ANDROID_PACKAGE  — default: com.example.flutter_amrit
#   ANDROID_DB_PATH  — default: app_flutter/db.sqlite
#   ADB              — default: adb
#
# WSL + emulator on Windows: ensure adb sees the device first, e.g.:
#   adb devices
#   adb connect 127.0.0.1:5555   # if the emulator is not listed
#
# Requires a debug build (run-as). Run the app once so Drift creates the database.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LINK_PATH="$ROOT_DIR/.dev/db.sqlite"
PACKAGE="${ANDROID_PACKAGE:-com.example.flutter_amrit}"
REMOTE_PATH="${ANDROID_DB_PATH:-app_flutter/db.sqlite}"
ADB="${ADB:-adb}"

if ! command -v "$ADB" >/dev/null 2>&1; then
  echo "adb not found. Install Android platform-tools or set ADB=/path/to/adb." >&2
  exit 1
fi

if ! "$ADB" get-state >/dev/null 2>&1; then
  echo "No Android device or emulator connected." >&2
  echo "Run 'adb devices' and start an emulator or plug in a device." >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/.dev"

if ! "$ADB" exec-out run-as "$PACKAGE" cat "$REMOTE_PATH" >"$LINK_PATH" 2>/dev/null; then
  echo "Could not read $REMOTE_PATH for $PACKAGE." >&2
  echo "Install a debug build, run the app once, then retry." >&2
  exit 1
fi

if [[ ! -s "$LINK_PATH" ]]; then
  rm -f "$LINK_PATH"
  echo "Pulled file is empty — database may not exist yet." >&2
  exit 1
fi

count="$(sqlite3 "$LINK_PATH" "SELECT COUNT(*) FROM platforms;" 2>/dev/null || echo "?")"

echo "Pulled Android DB → $LINK_PATH"
echo "Package: $PACKAGE"
echo "Platforms: $count"
echo ""
echo "DBeaver: New Connection → SQLite → Path:"
echo "  $LINK_PATH"
echo ""
echo "Re-run after reinstalling the app or to refresh DBeaver."
