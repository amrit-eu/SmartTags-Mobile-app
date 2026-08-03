import 'package:connectivity_plus/connectivity_plus.dart';

/// Returns true when the device has an active network interface.
bool isDeviceOnline(ConnectivityResult? result) {
  return result != null && result != ConnectivityResult.none;
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
        case 'other':
          networkType = 'Other';
        default:
          networkType = 'Network';
      }

      message = 'Network connection available ($networkType)';
    }
  }
  return message;
}
