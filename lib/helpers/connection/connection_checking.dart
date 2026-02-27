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

/// A helper function that returns a user-friendly message based on the connectivity status.
String getConnectionMessage(ConnectivityResult? result) {
  var message = 'Connection status is not known';
  if (result != null) {
    if (result == ConnectivityResult.none) {
      message = 'Network connection lost';
    } else {
      var networkType = result.name;

      switch (result.name) {
        case 'bluetooth':
          networkType = 'Bluetooth';
        case 'wifi':
          networkType = 'WiFi';
        case 'ethernet':
          networkType = 'Ethernet';
        case 'mobile':
          networkType = 'Mobile';
        case 'vpn':
          networkType = 'VPN';
        default:
          networkType = 'Unknown network type';
      }

      message = 'Network connection available ($networkType)';
    }
  }
  return message;
}
