# Cursor Cloud Agent base image for SmartTags (Flutter + Dart).
# Do not COPY the app — Cursor clones the repo at agent/build time.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils zip \
    openjdk-17-jdk clang cmake ninja-build pkg-config \
    libgtk-3-dev libstdc++-12-dev jq \
    && rm -rf /var/lib/apt/lists/*

# Match release workflows (see .github/workflows/release-*.yml).
ARG FLUTTER_VERSION=3.47.0
RUN git clone https://github.com/flutter/flutter.git /opt/flutter \
    && cd /opt/flutter \
    && git fetch --tags --depth 1 \
    && git checkout "${FLUTTER_VERSION}"

ENV PATH="/opt/flutter/bin:${PATH}"

RUN flutter config --no-analytics \
    && flutter precache \
    && flutter doctor -v

RUN useradd -m -s /bin/bash ubuntu

USER ubuntu
WORKDIR /home/ubuntu
