#!/usr/bin/env bash
# Cloud sessions only — local Claude Code exits without touching the machine.
set -euo pipefail

if [[ "${CLAUDE_CODE_REMOTE:-}" != "true" ]]; then
	exit 0
fi

cd "${CLAUDE_PROJECT_DIR:?}"

export PATH="/opt/flutter/bin:${PATH}"

if ! command -v flutter >/dev/null 2>&1; then
	echo "::error::Flutter missing. Add .claude/cloud-setup.sh to your Claude cloud environment Setup script."
	exit 1
fi

flutter pub get

if [[ -f tool/build_seed_database.dart ]]; then
	dart run tool/build_seed_database.dart --schema-only
fi

echo "SmartTags cloud session ready. Try: flutter analyze && flutter test"
