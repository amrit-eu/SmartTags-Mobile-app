import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/offline_access_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';
import 'package:smart_tags/widgets/offline_access_banner.dart';

import '../utils/fake_auth_notifiers.dart';
import '../utils/test_user.dart';

/// Lets a test switch the expiry condition on and off.
class _Expired extends Notifier<bool> {
  @override
  bool build() => true;

  bool get expired => state;

  set expired(bool value) => state = value;
}

final _expired = NotifierProvider<_Expired, bool>(_Expired.new);

/// Connectivity a test can switch, offline by default.
class _Connectivity extends ConnectivityStatus {
  @override
  FutureOr<ConnectivityResult?> build() async => ConnectivityResult.none;

  ConnectivityResult? get result => state.value;

  set result(ConnectivityResult? value) => state = AsyncValue.data(value);
}

/// Pumps the banner for a signed-in user whose expiry is driven by [_expired]
/// and connectivity by [_Connectivity].
Future<ProviderContainer> _pumpBanner(
  WidgetTester tester, {
  bool expired = true,
  ConnectivityResult connectivity = ConnectivityResult.none,
}) async {
  final container = ProviderContainer(
    overrides: [
      offlineAccessExpiredProvider.overrideWith((ref) => ref.watch(_expired)),
      authProvider.overrideWith(() => FakeAuthNotifier(createTestUser())),
      checkConnectionProvider.overrideWith(_Connectivity.new),
    ],
  );
  addTearDown(container.dispose);
  // Keep the auth state loaded and live, as the app bar does in the app.
  container.listen(authProvider, (_, _) {});
  await container.read(authProvider.future);
  await container.read(checkConnectionProvider.future);
  container.read(_expired.notifier).expired = expired;
  (container.read(checkConnectionProvider.notifier) as _Connectivity).result = connectivity;

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: OfflineAccessBanner())),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('shows a warning explaining that online reauthentication is required', (tester) async {
    await _pumpBanner(tester);

    expect(find.text(offlineAccessExpiredMessage), findsOneWidget);
    final banner = tester.widget<AppStatusBanner>(find.byType(AppStatusBanner));
    expect(banner.severity, AppStatusBannerSeverity.warning);
    expect(find.widgetWithText(TextButton, 'Log in'), findsOneWidget);
  });

  testWidgets('is hidden while offline access is valid', (tester) async {
    await _pumpBanner(tester, expired: false);

    expect(find.byType(AppStatusBanner), findsNothing);
  });

  testWidgets('is hidden while online, where the session is renewed in the background', (tester) async {
    await _pumpBanner(tester, connectivity: ConnectivityResult.wifi);

    expect(find.byType(AppStatusBanner), findsNothing);
  });

  testWidgets('appears when connectivity is lost with expired access', (tester) async {
    final container = await _pumpBanner(tester, connectivity: ConnectivityResult.wifi);

    (container.read(checkConnectionProvider.notifier) as _Connectivity).result = ConnectivityResult.none;
    await tester.pump();

    expect(find.text(offlineAccessExpiredMessage), findsOneWidget);
  });

  testWidgets('Log in opens the login screen', (tester) async {
    await _pumpBanner(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(UserLoginScreen), findsOneWidget);
  });

  testWidgets('a dismissed banner shows again after access is restored and expires again', (tester) async {
    final container = await _pumpBanner(tester);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
    await tester.pump();
    expect(find.text(offlineAccessExpiredMessage), findsNothing);

    container.read(_expired.notifier).expired = false;
    await tester.pump();
    expect(find.text(offlineAccessExpiredMessage), findsNothing);

    container.read(_expired.notifier).expired = true;
    await tester.pump();
    expect(find.text(offlineAccessExpiredMessage), findsOneWidget);
  });

  testWidgets('a dismissed banner shows again after reconnecting and going offline again', (tester) async {
    final container = await _pumpBanner(tester);
    final connectivity = container.read(checkConnectionProvider.notifier) as _Connectivity;

    await tester.tap(find.widgetWithIcon(IconButton, Icons.close));
    await tester.pump();
    expect(find.text(offlineAccessExpiredMessage), findsNothing);

    connectivity.result = ConnectivityResult.wifi;
    await tester.pump();
    connectivity.result = ConnectivityResult.none;
    await tester.pump();

    expect(find.text(offlineAccessExpiredMessage), findsOneWidget);
  });
}
