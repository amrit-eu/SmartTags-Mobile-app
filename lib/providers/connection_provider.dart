import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that checks the device's connectivity status and updates in real-time.
final checkConnectionProvider = AsyncNotifierProvider<ConnectivityStatus, ConnectivityResult?>(ConnectivityStatus.new);

/// An AsyncNotifier that listens to connectivity changes and updates the state accordingly.
class ConnectivityStatus extends AsyncNotifier<ConnectivityResult?> {
  late StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  FutureOr<ConnectivityResult?> build() async {
    final connectivity = Connectivity();
    // Emit initial connectivity status
    final initialResults = await connectivity.checkConnectivity();
    final initialStatus = initialResults.isEmpty ? null : initialResults[0];
    state = AsyncValue.data(initialStatus);
    // Listen for connectivity changes and update state
    _sub = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final connectivityStatus = result.isEmpty ? null : result[0];
      state = AsyncValue.data(connectivityStatus);
    }, onError: (e, StackTrace st) => state = AsyncValue.error(Null, st));
    ref.onDispose(() => _sub.cancel());
    return initialStatus;
  }
}
