// Tests for connection helper methods.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/helpers/connection/connection_checking.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check that a connectivity results return the correct message.', () async {
    final message = getConnectionMessage(ConnectivityResult.none);
    expect(message, 'Network connection lost');
    final message2 = getConnectionMessage(ConnectivityResult.wifi);
    expect(message2, 'Network connection available (WiFi)');
    final message3 = getConnectionMessage(null);
    expect(message3, 'Connection status is not known');
    final message4 = getConnectionMessage(ConnectivityResult.bluetooth);
    expect(message4, 'Network connection available (Bluetooth)');
    final message5 = getConnectionMessage(ConnectivityResult.ethernet);
    expect(message5, 'Network connection available (Ethernet)');
    final message6 = getConnectionMessage(ConnectivityResult.mobile);
    expect(message6, 'Network connection available (Mobile)');
    final message7 = getConnectionMessage(ConnectivityResult.vpn);
    expect(message7, 'Network connection available (VPN)');
  });
}
