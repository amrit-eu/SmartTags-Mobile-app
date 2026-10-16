import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/screens/alert_details_screen.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/widgets/common/app_snack_bar.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';
import 'package:smart_tags/widgets/pending_operations_banner.dart';

import '../utils/fake_auth_notifiers.dart';
import '../utils/test_user.dart';

class _Connection extends ConnectivityStatus {
  _Connection(this.result);

  final ConnectivityResult result;

  @override
  FutureOr<ConnectivityResult?> build() => result;
}

class _Gateway extends GatewayRepository {
  _Gateway(AppDatabase database, {this.error}) : super(authService: AuthService(authDao: database.authDao));

  final GatewayException? error;

  @override
  Future<void> submitAlertOperationJson(PendingOperationKind kind, String payloadJson) async {
    if (error case final error?) throw error;
  }
}

class _NoRefresh extends PlatformsRefreshNotifier {
  @override
  Future<void> refreshAfterDelay() async {}
}

const _alert = Alert(
  id: 'alert-1',
  resource: 'PLT-1',
  event: 'Low battery',
  severity: AlertSeverity.warning,
  status: AlertStatus.open,
  description: 'Battery low',
  service: 'service',
  previousSeverity: AlertSeverity.normal,
  duplicateCount: 0,
  alertCategory: 'category',
  country: 'country',
);

Future<void> _expectTransientFeedback(
  WidgetTester tester,
  String message, {
  AppSnackBarSeverity severity = AppSnackBarSeverity.info,
}) async {
  expect(find.text(message), findsOneWidget);
  final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
  expect(snackBar.duration, appSnackBarDuration);
  expect(snackBar.persist, isNot(true));
  final icon = switch (severity) {
    AppSnackBarSeverity.info => Icons.info_outline,
    AppSnackBarSeverity.success => Icons.check_circle_outline,
    AppSnackBarSeverity.warning => Icons.warning_amber_outlined,
    AppSnackBarSeverity.error => Icons.error_outline,
  };
  expect(find.descendant(of: find.byType(SnackBar), matching: find.byIcon(icon)), findsOneWidget);

  await tester.pump(appSnackBarDuration);
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.byType(SnackBar), findsNothing);
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.executor(conn.inMemoryConnection());
  });

  Future<void> seedDatabase() async {
    await database.insertPlatforms([
      PlatformsCompanion.insert(
        ref: _alert.resource,
        programId: const Value(4),
        programName: const Value('Argo Australia'),
        programCode: const Value('argo-australia'),
        model: 'ARVOR',
        network: 'Argo',
        category: 'Float',
        lat: 0,
        lon: 0,
        status: 'OPERATIONAL',
        operationalStatus: 'Deployed',
        lastUpdated: DateTime.utc(2026),
        operationLat: 0,
        operationLon: 0,
      ),
    ]);
    await database.upsertAlerts([
      AlertsCompanion.insert(
        id: _alert.id,
        resource: _alert.resource,
        event: _alert.event,
        severity: 'warning',
        status: 'open',
        description: _alert.description,
        service: _alert.service,
        previousSeverity: 'normal',
        duplicateCount: 0,
        alertCategory: _alert.alertCategory,
        country: _alert.country,
      ),
    ]);
  }

  void testFeedback(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(database.close);
      }
    });
  }

  Future<void> mount(WidgetTester tester, {bool online = true, GatewayException? error}) async {
    await seedDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
          checkConnectionProvider.overrideWith(
            () => _Connection(online ? ConnectivityResult.wifi : ConnectivityResult.none),
          ),
          gatewayRepositoryProvider.overrideWithValue(_Gateway(database, error: error)),
          platformsRefreshProvider.overrideWith(_NoRefresh.new),
        ],
        child: const MaterialApp(home: AlertDetailsScreen(alert: _alert)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testFeedback('acknowledgement success feedback expires after four seconds', (tester) async {
    await mount(tester);
    await tester.tap(find.text('Acknowledge'));
    await tester.pumpAndSettle();

    await _expectTransientFeedback(tester, 'Alert acknowledged', severity: AppSnackBarSeverity.success);
  });

  testFeedback('rejected alert actions use transient feedback and do not queue work', (tester) async {
    await mount(tester, error: const GatewayException('Forbidden', statusCode: 403));
    await tester.tap(find.text('Acknowledge'));
    await tester.pumpAndSettle();

    await _expectTransientFeedback(tester, 'Forbidden', severity: AppSnackBarSeverity.error);
    expect(await database.getPendingOperationsOrdered(), isEmpty);
  });

  testFeedback('queued alert action remains visible above scrolling content after feedback expires', (tester) async {
    await mount(tester, online: false);
    await tester.tap(find.text('Acknowledge'));
    await tester.pumpAndSettle();

    await _expectTransientFeedback(tester, 'Alert acknowledged. Saved locally and queued for sync.');
    final banner = find.descendant(
      of: find.byType(PendingOperationsBanner),
      matching: find.byType(AppStatusBanner),
    );
    expect(find.text('1 operation queued'), findsOneWidget);
    expect(tester.widget<AppStatusBanner>(banner).severity, AppStatusBannerSeverity.info);
    expect(find.ancestor(of: banner, matching: find.byType(Scrollable)), findsNothing);
    final top = tester.getTopLeft(banner);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(banner), top);

    await tester.tap(find.descendant(of: banner, matching: find.byTooltip('Dismiss banner')));
    await tester.pump();
    expect(find.text('1 operation queued'), findsNothing);
  });

  testFeedback('adding a note uses transient feedback while the queued note stays visible', (tester) async {
    await mount(tester, online: false);
    await tester.tap(find.text('Add a note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Check battery');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await _expectTransientFeedback(tester, 'Note added. Saved locally and queued for sync.');
    expect(find.text('1 operation queued'), findsOneWidget);
    expect((await database.getPendingOperationsOrdered()).single.action, 'alert_note');
  });
}
