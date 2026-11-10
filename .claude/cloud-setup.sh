#!/bin/bash
# Claude Code cloud environment — Setup script (Choose file in claude.ai/code).
# Not run from the repo automatically; attach this file to your cloud environment.
# Aim for under ~5 minutes so the environment can be cached.
set -euo pipefail

FLUTTER_ROOT=/opt/flutter
export DEBIAN_FRONTEND=noninteractive

if command -v sudo >/dev/null 2>&1; then
	SUDO=sudo
else
	SUDO=
fi

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
	$SUDO apt-get update
	$SUDO apt-get install -y --no-install-recommends \
		ca-certificates curl git unzip xz-utils zip \
		openjdk-17-jdk clang cmake ninja-build pkg-config libgtk-3-dev
	$SUDO git clone https://github.com/flutter/flutter.git "${FLUTTER_ROOT}"
	cd "${FLUTTER_ROOT}"
	git fetch --tags --depth 1
	git checkout 3.47.0
fi

export PATH="${FLUTTER_ROOT}/bin:${PATH}"
flutter config --no-analytics
flutter precache
flutter doctor -v

echo "Flutter ${FLUTTER_ROOT} ready for SmartTags sessions."
