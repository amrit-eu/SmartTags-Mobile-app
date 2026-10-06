import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/models/passport_filter_dto.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/services/gateway_repository.dart';

/// The catalogue receives the same result regardless of where it was loaded.
class QrPassportLookupResult {
  /// The matching passport rows for one physical QR reference.
  const QrPassportLookupResult({required this.reference, required this.platforms});

  /// The reference value read from the QR sticker.
  final String reference;

  /// List of platforms to display in the catalogue.
  final List<Platform> platforms;
}

/// Current state of the scan lookup.
enum QrLookupPhase {
  /// No active scan.
  idle,

  /// A lookup is running.
  loading,

  /// A lookup completed.
  data,

  /// A lookup failed.
  error,
}

/// State consumed by the catalogue.
class QrLookupState {
  /// Creates a lookup state.
  const QrLookupState({required this.phase, this.reference, this.result, this.message});

  /// Creates an empty state.
  const QrLookupState.idle() : this(phase: QrLookupPhase.idle);

  /// The stage of the lookup.
  final QrLookupPhase phase;

  /// The active QR reference.
  final String? reference;

  /// The successful lookup output.
  final QrPassportLookupResult? result;

  /// A human readable message (used for error states).
  final String? message;
}

/// Performs the QR reference lookup.
class QrPassportLookupRepository {
  /// Creates a lookup repository with a connectivity source.
  const QrPassportLookupRepository({
    required this.database,
    required this.gateway,
    required this.connectivity,
  });

  /// Local passport store.
  final AppDatabase database;

  /// Passport API.
  final GatewayRepository gateway;

  /// Returns current connectivity state.
  final Future<ConnectivityResult?> Function() connectivity;

  /// Loads every passport for a given [reference] from the selected source.
  Future<QrPassportLookupResult> lookupByQrCode(String reference) async {
    // If no connectivity, return local DB results.
    if (!isDeviceOnline(await connectivity())) {
      return _local(reference, reason: 'device offline');
    }
    // else, try to fetch from the Gateway API.
    try {
      final response = await gateway.searchPassports(
        PassportFilterDto(paginationEnabled: false, filters: {'qrCode': reference}),
      );
      final matched = <String, PlatformsCompanion>{};
      for (final platform in response.platforms) {
        if (platform.qrCode.value == reference && platform.ref.value.isNotEmpty) {
          matched[platform.ref.value] = platform;
        }
      }
      if (matched.isNotEmpty) {
        await database.transaction(() async {
          await database.upsertPlatforms(matched.values.toList());
          await database.upsertAlerts(
            response.alerts.where((alert) => matched.containsKey(alert.resource.value)).toList(),
          );
        });
      }
      // Read persisted rows so each card and the details page see the same data.
      final rows = await database.getPlatformsByQrCode(reference);
      return QrPassportLookupResult(
        reference: reference,
        platforms: _ordered(rows.where((row) => matched.containsKey(row.ref))),
      );
    } on Object catch (error) {
      // If the Gateway request fails, fall back to local DB results.
      if (error is http.ClientException) {
        return _local(reference, reason: 'Gateway transport failure');
      }
      if (!isDeviceOnline(await connectivity())) {
        return _local(reference, reason: 'connection lost during Gateway request');
      }
      rethrow;
    }
  }

  /// Loads every passport for a given [reference] from the local database.
  Future<QrPassportLookupResult> _local(String reference, {required String reason}) async {
    final rows = await database.getPlatformsByQrCode(reference);
    if (kDebugMode) {
      debugPrint('QR passport lookup: using local DB for $reference ($reason); ${rows.length} passport(s) found');
    }
    return QrPassportLookupResult(reference: reference, platforms: _ordered(rows));
  }

  /// Orders the rows by latest operation date, then by reference.
  List<Platform> _ordered(Iterable<Platform> rows) {
    final byRef = {for (final row in rows) row.ref: row};
    final result = byRef.values.toList()
      ..sort((a, b) {
        final aDate = a.latestOperationDate ?? a.lastUpdated;
        final bDate = b.latestOperationDate ?? b.lastUpdated;
        final dateOrder = bDate.compareTo(aDate);
        return dateOrder != 0 ? dateOrder : a.ref.compareTo(b.ref);
      });
    return result;
  }
}

/// The lookup repository provider used by scan state.
final qrPassportLookupRepositoryProvider = Provider<QrPassportLookupRepository>((ref) {
  return QrPassportLookupRepository(
    database: ref.watch(databaseProvider),
    gateway: ref.watch(gatewayRepositoryProvider),
    connectivity: () async {
      final current = ref.read(checkConnectionProvider);
      if (current.hasValue || current.hasError) return current.value;
      try {
        return await ref.read(checkConnectionProvider.future).timeout(const Duration(seconds: 5));
      } on Object {
        return null;
      }
    },
  );
});

/// Shared scan state.
final qrPassportLookupProvider = NotifierProvider<QrPassportLookupNotifier, QrLookupState>(
  QrPassportLookupNotifier.new,
);

/// Controls lookup, retry, and clearing of a scanned reference.
class QrPassportLookupNotifier extends Notifier<QrLookupState> {
  int _requestId = 0;

  @override
  QrLookupState build() => const QrLookupState.idle();

  /// Starts a lookup and replaces any previous scan result.
  Future<void> lookup(String reference) async {
    // requestId used to ignore any previous lookup result.
    final requestId = ++_requestId;
    state = QrLookupState(phase: QrLookupPhase.loading, reference: reference);
    try {
      final result = await ref.read(qrPassportLookupRepositoryProvider).lookupByQrCode(reference);
      if (requestId == _requestId) {
        state = QrLookupState(phase: QrLookupPhase.data, reference: reference, result: result);
      }
    } on Object {
      if (requestId == _requestId) {
        state = QrLookupState(
          phase: QrLookupPhase.error,
          reference: reference,
          message: 'Could not look up passports for this QR code. Please retry.',
        );
      }
    }
  }

  /// Repeats the lookup with the same reference.
  Future<void> retry() async {
    final reference = state.reference;
    if (reference != null) await lookup(reference);
  }

  /// Clears the active scan and ignores any outstanding response.
  void clear() {
    _requestId++;
    state = const QrLookupState.idle();
  }
}
