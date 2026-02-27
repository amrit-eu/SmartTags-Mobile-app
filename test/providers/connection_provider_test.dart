// Test for connection provider.

// Tests for connection checking.
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/connection/native.dart' as conn;
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/main.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';

// Test AsyncNotifier for overriding checkConnectionProvider
class TestConnectivityStatus extends ConnectivityStatus {
  ConnectivityResult? _testValue;
  @override
  FutureOr<ConnectivityResult?> build() async {
    // Do not start any real listeners or async operations
    return _testValue;
  }

  void set(ConnectivityResult? value) {
    _testValue = value;
    state = AsyncValue.data(value);
  }
}

void main() {
  testWidgets('Snackbar is displayed when connectivity provider updates with AsyncNotifier.', (
    WidgetTester tester,
  ) async {
    final testNotifier = TestConnectivityStatus();
    final mockDatabase = AppDatabase.executor(conn.inMemoryConnection());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkConnectionProvider.overrideWith(() => testNotifier),
          initialSyncProvider.overrideWithValue(const AsyncValue.data(null)),
          databaseProvider.overrideWithValue(mockDatabase),
          platformsStreamProvider.overrideWithValue(const AsyncValue.data([])),
        ],
        child: const MyApp(),
      ),
    );

    testNotifier.set(ConnectivityResult.wifi);
    // Allow time for the UI to update and show the SnackBar.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Network connection available (WiFi)'), findsOneWidget);
  });
}
