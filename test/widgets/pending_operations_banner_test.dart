import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/screens/pending_operations_screen.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';
import 'package:smart_tags/widgets/pending_operations_banner.dart';

PendingPassportEvent _event({
  int id = 1,
  PendingOperationStatus status = PendingOperationStatus.pending,
  int attempts = 0,
  String? lastError,
}) {
  return PendingPassportEvent(
    id: id,
    platformRef: 'PLT-$id',
    action: DeployAction.deploy,
    payloadJson: '{}',
    createdAt: DateTime.utc(2026),
    status: status,
    attempts: attempts,
    lastError: lastError,
  );
}

Future<void> _pumpBanner(
  WidgetTester tester,
  Stream<List<PendingPassportEvent>> events,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pendingPassportEventsProvider.overrideWith(
          (ref) => events,
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: PendingOperationsBanner(),
        ),
      ),
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('shows and dismisses queued operations banner', (
    tester,
  ) async {
    await _pumpBanner(
      tester,
      Stream.value([_event()]),
    );

    expect(
      find.text('1 operation queued'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    final banner = tester.widget<AppStatusBanner>(
      find.byType(AppStatusBanner),
    );

    expect(
      banner.severity,
      AppStatusBannerSeverity.info,
    );

    final dismissButton = find.widgetWithIcon(
      IconButton,
      Icons.close,
    );

    expect(dismissButton, findsOneWidget);

    await tester.tap(dismissButton);
    await tester.pump();

    expect(
      find.text('1 operation queued'),
      findsNothing,
    );
  });

  testWidgets('shows failed operations as an error with View action', (
    tester,
  ) async {
    await _pumpBanner(
      tester,
      Stream.value([
        _event(),
        _event(
          id: 2,
          status: PendingOperationStatus.failed,
          attempts: 1,
          lastError: 'Gateway unavailable',
        ),
      ]),
    );

    expect(
      find.text('2 operations queued, 1 failed'),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.sync_problem),
      findsOneWidget,
    );

    final banner = tester.widget<AppStatusBanner>(
      find.byType(AppStatusBanner),
    );

    expect(
      banner.severity,
      AppStatusBannerSeverity.error,
    );

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    expect(
      find.byType(PendingOperationsScreen),
      findsOneWidget,
    );
  });

  testWidgets('shows dismissed banner again when queue status changes', (
    tester,
  ) async {
    final controller = StreamController<List<PendingPassportEvent>>();

    addTearDown(controller.close);

    controller.add([_event()]);

    await _pumpBanner(
      tester,
      controller.stream,
    );

    expect(
      find.text('1 operation queued'),
      findsOneWidget,
    );

    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.close),
    );
    await tester.pump();

    expect(
      find.text('1 operation queued'),
      findsNothing,
    );

    controller.add([
      _event(
        status: PendingOperationStatus.failed,
        attempts: 1,
        lastError: 'Gateway unavailable',
      ),
    ]);

    await tester.pump();
    await tester.pump();

    expect(
      find.text('1 operation queued, 1 failed'),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.sync_problem),
      findsOneWidget,
    );
  });

  testWidgets('hides banner when queue is empty', (
    tester,
  ) async {
    await _pumpBanner(
      tester,
      Stream.value(const <PendingPassportEvent>[]),
    );

    expect(
      find.byType(AppStatusBanner),
      findsNothing,
    );
  });
}
