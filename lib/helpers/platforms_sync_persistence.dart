import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';
import 'package:smart_tags/services/gateway_passport_mapper.dart';

/// Writes [result] to Drift (save phase uses indeterminate banner, no `N/M`).
Future<void> persistGatewayPassportsResult({
  required Ref ref,
  required AppDatabase db,
  required GatewayPassportsResult result,
  required bool replaceAll,
}) async {
  if (result.platforms.isEmpty && result.alerts.isEmpty) {
    return;
  }

  ref.read(platformsSyncPhaseProvider.notifier).setSaving();

  if (replaceAll) {
    await db.syncPlatforms(result.platforms);
  } else {
    await db.upsertPlatforms(result.platforms);
  }
  await db.upsertAlerts(result.alerts);
  await db.deleteOrphanedAlerts();
}
