# SmartTags (Flutter)

Mobile app for ship operators: ocean platform map, offline Drift DB, QR scan, Amrit gateway sync.

**Claude Code (web):** use [`.claude/CLAUDE.md`](.claude/CLAUDE.md) and attach [`.claude/cloud-setup.sh`](.claude/cloud-setup.sh) to your cloud environment.

## Layout

- `lib/screens/`, `lib/widgets/` — UI
- `lib/services/`, `lib/providers/` — API, sync, Riverpod
- `lib/database/` — Drift schema
- `lib/theme/` — theming and touch-target sizing (#46)
- `test/` — unit/widget tests

## Conventions

- Follow `very_good_analysis` / `analysis_options.yaml`
- Keep business logic out of `build()` — use services and providers
- Preserve offline-first behavior unless the task says otherwise
- Run `flutter analyze` and `flutter test` before finishing substantive changes

## Cursor Cloud instructions

Cloud Agents use `.cursor/environment.json` (Ubuntu + Flutter 3.47.0). After the environment **Build** succeeds:

1. **Verify toolchain**
   ```bash
   flutter --version
   flutter pub get
   ```
2. **Checks (same as CI install script)**
   ```bash
   flutter analyze
   flutter test
   ```
3. **Optional local UI** (web only on Linux VM — not iOS simulator):
   ```bash
   flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
   ```
   Open forwarded port **8080** from the agent UI.

**Gateway / VPN:** Production data (`amrit.isival.ifremer.fr`) may require VPN. Cloud VMs often cannot reach it; use mocked data or schema-only local DB for agent work unless secrets/VPN are configured in the dashboard.

**Model (parent agent):** Pick your model in the Cloud Agent UI or dashboard — repo config does not pin it.
