import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_tags/helpers/scaffold_messenger.dart';

/// Checks for a network connection and lets the app know of network
/// changes by displaying a SnackBar with the details.
class CheckConnection {

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// Initialise connection checking.
  void init() {
    _connectivitySubscription =
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
   unawaited(_checkConnectivity());
  }

  /// Stop connection checking.
  void stop() {
    unawaited(_connectivitySubscription.cancel());
  }

  Future<void> _checkConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      result = [];
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    var message = 'Connection status is not known.';

    if (result.isNotEmpty) {
      if (result[0] == ConnectivityResult.none) {
        message = 'You are not connected to any network';
      } else {
        message = 'You are now connected to ${result[0].name}';
      }
    }

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message))
    );
  }
}
