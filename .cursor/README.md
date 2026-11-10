# Cursor Cloud environment — SmartTags-Mobile-app

Configuration file: `.cursor/environment.json` (this folder).

## Dashboard setup

1. [Cloud Agents](https://cursor.com/dashboard?tab=cloud-agents) → **Environments** → open **SmartTags-Mobile-app** (or create it).
2. **Manage repositories** → select **`amrit-eu/SmartTags-Mobile-app`** only (single-repo environment).
3. **environment.json location** → this repo, path **`.cursor/environment.json`** (not “skip file”).
4. **Default model** (environment or team settings) → your preferred model (e.g. Claude Sonnet).
5. **Trigger build** on the branch you use (`main` after merge, or a feature branch for trials).
6. Wait until **Build** status is green before starting agents.

Optional dashboard **Secrets** (never commit): `SMART_TAGS_GATEWAY_BASE_URL` if the agent must hit a non-default Gateway.

## How to test in Cursor

### A. Cloud Agent (full VM)

1. **Agents** panel → choose environment **SmartTags-Mobile-app**.
2. Pick branch (e.g. `46-resize-buttons-and-clickable-items-accessibility`).
3. Confirm the latest **Build** for that branch succeeded (environment page → Builds).
4. Start an agent with a smoke prompt, for example:
   ```text
   Run flutter analyze and flutter test; summarize failures only.
   ```
5. Watch the run log; open forwarded port **8080** only if you started Flutter web.

### B. Local agent (your machine)

1. Open repo in Cursor.
2. Same checks: `flutter pub get && flutter analyze && flutter test`
3. iOS simulator: `./scripts/smartrun.sh` (Mac only).

### C. Bugbot (GitHub PR — separate product)

Enable repo under **Automations → Bugbot** (`amrit-eu`), **Manual only**, then PR comment: `bugbot run`.

## Files

| File | Purpose |
| --- | --- |
| `environment.json` | Install script, egress allowlist, Docker build |
| `Dockerfile` | Flutter SDK + Java 17 base image |
| `../AGENTS.md` | Instructions read by cloud and local agents |
