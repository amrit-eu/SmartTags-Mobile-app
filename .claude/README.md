# Claude Code — SmartTags cloud environment

This folder configures **[Claude Code on the web](https://claude.ai/code)** for `amrit-eu/SmartTags-Mobile-app`. It does **not** apply to **Cursor Cloud Agents** (see `.cursor/README.md`).

| File | Purpose |
| --- | --- |
| [`CLAUDE.md`](CLAUDE.md) | Project instructions Claude loads every session |
| [`cloud-setup.sh`](cloud-setup.sh) | **Environment setup script** — install once per cloud environment (Flutter 3.47.0) |
| [`session-start.sh`](session-start.sh) | Runs on each cloud session start (`flutter pub get`, optional schema-only seed) |
| [`settings.json`](settings.json) | `SessionStart` hook → `session-start.sh` |

Claude does **not** run these scripts from GitHub until you attach them to a cloud environment.

## One-time: create the cloud environment

1. **claude.ai/code** → cloud icon → **Add environment** (or edit).
2. **Setup script** → **Choose file** → this repo’s `.claude/cloud-setup.sh`.
   - Installs Flutter under `/opt/flutter` and runs `flutter doctor`.
   - Keep under ~5 minutes so the environment can be cached.
3. **Save.**

No Gateway call happens in the setup script — only the Flutter toolchain.

## Start a session

1. Repository: **`amrit-eu/SmartTags-Mobile-app`**, branch of your choice (`main` after merge).
2. Select the environment you configured above.
3. On **startup**, `settings.json` runs `session-start.sh` when `CLAUDE_CODE_REMOTE=true`.
4. Smoke prompt:

```text
Do not change code. Run `flutter --version`, `flutter analyze`, and `flutter test`.
Report failures only.
```

## Local Claude Code (laptop)

- `session-start.sh` **exits immediately** (no hook side effects).
- Use your machine: `flutter pub get`, `flutter test`, `./scripts/smartrun.sh` (macOS + iOS Simulator).

## Gateway / Isival

The app talks to **`https://amrit.isival.ifremer.fr/amrit-gateway`** from **running app code**, not from these scripts.

Cloud VMs often **cannot** reach Isival (VPN). This environment does not auto-sync production data. For real API checks you need VPN or a reachable Gateway URL and a manual `curl` / app run — not part of default setup.

## Cursor vs Claude

| Tool | Config location |
| --- | --- |
| **Claude Code cloud** | `.claude/` (this folder) |
| **Cursor Cloud Agents** | `.cursor/environment.json` + dashboard |

Shared high-level notes also appear in [`AGENTS.md`](../AGENTS.md).
