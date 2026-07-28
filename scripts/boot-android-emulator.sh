#!/usr/bin/env bash
# Ensures an Android emulator or device is visible to adb (Linux, WSL, macOS).
#
# Usage:
#   ./scripts/boot-android-emulator.sh
#   ANDROID_AVD=Pixel_7_API_34 ./scripts/boot-android-emulator.sh
#
# Optional env:
#   ANDROID_AVD            — AVD name to launch if no device is connected (Linux / native macOS)
#   ADB                      — default: adb
#   WSL_ADB_HOST             — Windows host IP for WSL adb connect (auto-detected if unset)
#
# Experimental WSL cold-start (launch emulator on Windows from WSL):
#   WSL_LAUNCH_EMULATOR=1    — try Windows-side emulator launch before adb connect
#   WINDOWS_ANDROID_SDK      — e.g. /mnt/c/Users/you/AppData/Local/Android/Sdk
#   ANDROID_AVD              — e.g. Pixel_7_API_34
#
# Or uncomment the block marked "WSL experimental" in this script.

set -euo pipefail

ADB="${ADB:-adb}"

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

wsl_host_ip() {
  if [[ -n "${WSL_ADB_HOST:-}" ]]; then
    echo "$WSL_ADB_HOST"
    return
  fi
  awk '/nameserver/ { print $2; exit }' /etc/resolv.conf 2>/dev/null
}

adb_has_device() {
  "$ADB" get-state >/dev/null 2>&1
}

wait_for_device() {
  local attempts="${1:-30}"
  for _ in $(seq 1 "$attempts"); do
    if adb_has_device; then
      return 0
    fi
    sleep 2
  done
  return 1
}

connect_wsl_adb() {
  local host="$1"
  local port
  for port in 5555 5554; do
    "$ADB" connect "${host}:${port}" >/dev/null 2>&1 || true
  done
  "$ADB" connect "127.0.0.1:5555" >/dev/null 2>&1 || true
}

# Experimental — launch the Android emulator on Windows from WSL.
# Set WSL_LAUNCH_EMULATOR=1 to enable, or uncomment the WSL block below.
launch_wsl_windows_emulator() {
  local avd="${ANDROID_AVD:-}"
  local sdk="${WINDOWS_ANDROID_SDK:-}"

  if [[ -z "$avd" ]]; then
    echo "WSL experimental: set ANDROID_AVD to your AVD name (Android Studio > Device Manager)." >&2
    return 1
  fi

  if [[ -z "$sdk" ]]; then
    local user="${USER:-$(whoami)}"
    for candidate in \
      "/mnt/c/Users/${user}/AppData/Local/Android/Sdk" \
      "/mnt/c/Android/Sdk"; do
      if [[ -x "${candidate}/emulator/emulator.exe" ]]; then
        sdk="$candidate"
        break
      fi
    done
  fi

  local emulator_exe="${sdk}/emulator/emulator.exe"
  if [[ -z "$sdk" || ! -x "$emulator_exe" ]]; then
    echo "WSL experimental: set WINDOWS_ANDROID_SDK (e.g. /mnt/c/Users/you/AppData/Local/Android/Sdk)." >&2
    return 1
  fi

  echo "WSL experimental: launching $avd on Windows…"
  # Run the Windows .exe directly — avoids cmd.exe "start \"\" …" quoting bugs in WSL
  # (Windows may show "Cannot find '\\'" if cmd.exe is used with an empty title).
  "$emulator_exe" -avd "$avd" >/dev/null 2>&1 &
}

# Alternative one-liner (comment only — paste in shell to try manually):
#   /mnt/c/Users/you/AppData/Local/Android/Sdk/emulator/emulator.exe -avd Pixel_7_API_34 &

launch_avd() {
  local avd="$1"

  if command -v flutter >/dev/null 2>&1; then
    flutter emulators --launch "$avd" >/dev/null 2>&1 &
    return 0
  fi

  if command -v emulator >/dev/null 2>&1; then
    emulator -avd "$avd" >/dev/null 2>&1 &
    return 0
  fi

  echo "Cannot launch AVD $avd — install Flutter SDK or Android emulator." >&2
  return 1
}

resolve_avd() {
  if [[ -n "${ANDROID_AVD:-}" ]]; then
    echo "$ANDROID_AVD"
    return
  fi

  if command -v emulator >/dev/null 2>&1; then
    emulator -list-avds 2>/dev/null | head -1
    return
  fi

  if command -v flutter >/dev/null 2>&1; then
    flutter emulators 2>/dev/null | awk -F '•' 'NF > 1 { gsub(/^ +| +$/, "", $2); print $2; exit }'
  fi
}

if ! command -v "$ADB" >/dev/null 2>&1; then
  echo "adb not found. Install Android platform-tools or set ADB=/path/to/adb." >&2
  exit 1
fi

if adb_has_device; then
  echo "Android device ready ($("$ADB" get-state 2>/dev/null || echo connected))"
  exit 0
fi

if is_wsl; then
  host="$(wsl_host_ip)"

  # --- WSL experimental: uncomment to always try Windows emulator launch ---
  # if launch_wsl_windows_emulator; then
  #   sleep 5
  # fi

  if [[ "${WSL_LAUNCH_EMULATOR:-0}" == "1" ]]; then
    launch_wsl_windows_emulator || true
    sleep 5
  fi

  if [[ -n "$host" ]]; then
    echo "WSL: connecting adb to Windows host ($host)…"
    connect_wsl_adb "$host"
  else
    connect_wsl_adb "127.0.0.1"
  fi

  if wait_for_device 15; then
    echo "Android device ready via adb connect"
    exit 0
  fi

  # Give a cold-started emulator more time when WSL_LAUNCH_EMULATOR was used.
  if [[ "${WSL_LAUNCH_EMULATOR:-0}" == "1" ]] && wait_for_device 30; then
    echo "Android device ready via adb connect (after emulator boot)"
    exit 0
  fi

  echo "WSL: no emulator found via adb." >&2
  echo "Start the emulator in Android Studio on Windows, then retry." >&2
  echo "Or try: WSL_LAUNCH_EMULATOR=1 ANDROID_AVD=Your_AVD WINDOWS_ANDROID_SDK=/mnt/c/Users/you/AppData/Local/Android/Sdk ./scripts/smartrun-android.sh" >&2
  echo "Or run: adb connect 127.0.0.1:5555" >&2
  exit 1
fi

avd="$(resolve_avd || true)"
if [[ -z "$avd" ]]; then
  echo "No Android device connected and no AVD found." >&2
  echo "Create an AVD in Android Studio or set ANDROID_AVD." >&2
  exit 1
fi

echo "Launching Android emulator: $avd"
launch_avd "$avd"

if wait_for_device 45; then
  echo "Android emulator ready: $avd"
  exit 0
fi

echo "Emulator started but adb device not ready yet — try again in a few seconds." >&2
exit 1
