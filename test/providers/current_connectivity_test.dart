import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/providers/connection_provider.dart';

class _TestConnectivity extends ConnectivityStatus {
  _TestConnectivity(this.load);

  final FutureOr<ConnectivityResult?> Function() load;

  @override
  FutureOr<ConnectivityResult?> build() => load();
}

void main() {
  final lookupProvider = FutureProvider<ConnectivityResult?>(readCurrentConnectivity);

  ProviderContainer containerFor(_TestConnectivity connectivity) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [checkConnectionProvider.overrideWith(() => connectivity)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('returns cached connectivity', () async {
    final container = containerFor(_TestConnectivity(() => ConnectivityResult.wifi));
    await container.read(checkConnectionProvider.future);

    expect(await container.read(lookupProvider.future), ConnectivityResult.wifi);
  });

  test('waits for a loading connectivity check to finish', () async {
    final pending = Completer<ConnectivityResult?>();
    final container = containerFor(_TestConnectivity(() => pending.future));

    final result = container.read(lookupProvider.future);
    expect(container.read(lookupProvider).isLoading, isTrue);
    pending.complete(ConnectivityResult.mobile);

    expect(await result, ConnectivityResult.mobile);
  });

  test('returns null when a loading connectivity check fails', () async {
    final pending = Completer<ConnectivityResult?>();
    final container = containerFor(_TestConnectivity(() => pending.future));

    final result = container.read(lookupProvider.future);
    pending.completeError(StateError('Connectivity unavailable'));

    expect(await result, isNull);
  });

  testWidgets('returns null when connectivity takes longer than five seconds', (tester) async {
    final pending = Completer<ConnectivityResult?>();
    final container = containerFor(_TestConnectivity(() => pending.future));
    final result = container.read(lookupProvider.future);

    await tester.pump(const Duration(seconds: 5));
    expect(await result, isNull);
  });
}
