import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that checks the device's connectivity status and updates in real-time.
final checkConnectionProvider = AsyncNotifierProvider<ConnectivityStatus, ConnectivityResult?>(ConnectivityStatus.new);

/// Reads cached connectivity, or waits up to five seconds for it to load.
/// Returns `null` when connectivity fails or cannot be resolved in time.
Future<ConnectivityResult?> readCurrentConnectivity(Ref ref) async {
  final current = ref.read(checkConnectionProvider);
  final value = current.value;
  if (value != null) {
    return value;
  }
  if (current.hasError) {
    return null;
  }
  try {
    return await ref.read(checkConnectionProvider.future).timeout(const Duration(seconds: 5));
  } on Object {
    return null;
  }
}

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
    _sub = connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final connectivityStatus = result.isEmpty ? null : result[0];
      state = AsyncValue.data(connectivityStatus);
    }, onError: (Object e, StackTrace st) => state = AsyncValue.error(e, st));
    ref.onDispose(() => _sub.cancel());
    return initialStatus;
  }
}
