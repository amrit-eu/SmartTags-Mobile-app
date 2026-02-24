import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Checks for a network connection and lets the app know of network
/// changes by displaying a SnackBar with the details.
class CheckConnection {
  /// Creates an instance of CheckConnection, displaying a SnackBar on a provided 
  /// scaffold. 
  CheckConnection({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required Stream<List<ConnectivityResult>> connectivityStream
  }) {
    _scaffoldMessengerKey = scaffoldMessengerKey;
    _connectivityStream = connectivityStream;
  }

  final Connectivity _connectivity = Connectivity();
  late GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  late Stream<List<ConnectivityResult>> _connectivityStream;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// Initialise connection checking.
  void init() {
    _connectivitySubscription = _connectivityStream.listen(_updateConnectionStatus);
  }

  /// Check the connectivity now. Use at application startup.
  Future<void> check() async {
    await _checkConnectivity();
  }

  /// Stop connection checking.
  Future<void> stop() async {
    await _connectivitySubscription.cancel();
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

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    var message = 'Connection status is not known.';

    if (result.isNotEmpty) {
      if (result[0] == ConnectivityResult.none) {
        message = 'Network connection lost';
      } else {
        var networkType = result[0].name;

        switch (result[0].name) {
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

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message))
    );
  }
}
