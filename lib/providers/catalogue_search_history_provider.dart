import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/db_providers.dart';

/// Streams recent catalogue search entries (platform refs opened from results).
final catalogueSearchHistoryProvider = StreamProvider<List<CatalogueSearchHistory>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCatalogueSearchHistory();
});

/// Persists a catalogue history entry when the user opens a platform from search.
Future<void> recordCatalogueSearchHistory(
  WidgetRef ref, {
  required String platformRef,
  String? platformModel,
  String? wigosId,
}) {
  return ref.read(databaseProvider).recordCatalogueSearchEntry(
        platformRef: platformRef,
        platformModel: platformModel,
        wigosId: wigosId,
      );
}

/// Clears all catalogue search history on this device (#143).
Future<void> clearCatalogueSearchHistory(WidgetRef ref) {
  return ref.read(databaseProvider).clearCatalogueSearchHistory();
}
