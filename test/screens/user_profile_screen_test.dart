import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/pending_operation.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/screens/pending_operations_screen.dart';
import 'package:smart_tags/screens/user_profile.dart';

import '../utils/fake_auth_notifiers.dart';
import '../utils/test_user.dart';

PendingPassportEvent _event(int id, PendingOperationStatus status) => PendingPassportEvent(
  id: id,
  userRef: createTestUser().id,
  platformRef: 'PLATFORM-$id',
  kind: PendingOperationKind.deploy,
  payloadJson: '{}',
  createdAt: DateTime(2026),
  status: status,
  attempts: status == PendingOperationStatus.failed ? 1 : 0,
);

Future<void> _pumpProfile(WidgetTester tester, List<PendingPassportEvent> events) async {
  final user = createTestUser();
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuthNotifier(user)),
      pendingPassportEventsProvider.overrideWith((ref) => Stream.value(events)),
    ],
  );
  addTearDown(container.dispose);
  // The profile screen treats any auth data change as a logout, so the user
  // must already be loaded when it is shown (as it is in the app).
  await container.read(authProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: UserProfileScreen(user: user)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Profile shows an empty queued operations entry', (tester) async {
    await _pumpProfile(tester, const []);

    expect(find.text('Queued operations'), findsOneWidget);
    expect(find.text('No queued operations'), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
  });

  testWidgets('Profile shows queued and failed operation counts', (tester) async {
    await _pumpProfile(tester, [
      _event(1, PendingOperationStatus.pending),
      _event(2, PendingOperationStatus.failed),
    ]);

    expect(find.text('2 operations queued, 1 failed'), findsOneWidget);
    expect(find.byIcon(Icons.sync_problem), findsOneWidget);
  });

  testWidgets('Tapping queued operations opens the pending operations screen', (tester) async {
    await _pumpProfile(tester, [_event(1, PendingOperationStatus.pending)]);

    await tester.tap(find.text('Queued operations'));
    await tester.pumpAndSettle();

    expect(find.byType(PendingOperationsScreen), findsOneWidget);
    expect(find.text('Queued Operations'), findsOneWidget);
  });
}
