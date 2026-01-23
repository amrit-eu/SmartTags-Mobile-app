import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_tags/helpers/location/location_fetcher.dart';

void main() {
  const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');

  TestWidgetsFlutterBinding.ensureInitialized();

  test('getUserLocation returns valid LatLng from Position', () async {
    // Mock the Geolocator methods.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, (
      call,
    ) async {
      if (call.method == 'isLocationServiceEnabled') return true;
      if (call.method == 'checkPermission') {
        return LocationPermission.always.index;
      }
      if (call.method == 'getCurrentPosition') {
        return {
          'latitude': 10.0,
          'longitude': 20.0,
          'accuracy': 1.0,
          'altitude': 1.0,
          'heading': 1.0,
          'speed': 1.0,
          'speed_accuracy': 1.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
      return null;
    });

    final fetcher = LocationFetcher();
    final loc = await fetcher.getUserLocation();

    expect(loc?.latitude, 10);
    expect(loc?.longitude, 20);

    // Clean up the mock.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, null);
  });
  test('getUserLocation returns null for no permission', () async {
    // Mock the Geolocator methods.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, (
      call,
    ) async {
      if (call.method == 'isLocationServiceEnabled') return true;
      if (call.method == 'checkPermission' || call.method == 'requestPermission') {
        return LocationPermission.denied.index;
      }
      return null;
    });

    final fetcher = LocationFetcher();
    final printed = <String>[];
    final loc = await runZoned(
      // Used to capture stdout prints
      () async {
        return fetcher.getUserLocation();
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printed.add(line);
        },
      ),
    );

    expect(loc, isNull);
    expect(printed, contains('Location permission denied.'));

    // Clean up the mock.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, null);
  });
  test('getUserLocation returns null for denied forever permission', () async {
    // Mock the Geolocator methods.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, (
      call,
    ) async {
      if (call.method == 'isLocationServiceEnabled') return true;
      if (call.method == 'checkPermission') {
        return LocationPermission.denied.index;
      }
      if (call.method == 'requestPermission') {
        return LocationPermission.deniedForever.index;
      }
      return null;
    });

    final fetcher = LocationFetcher();
    final printed = <String>[];
    final loc = await runZoned(
      // Used to capture stdout prints
      () async {
        return fetcher.getUserLocation();
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          printed.add(line);
        },
      ),
    );

    expect(loc, isNull);
    expect(printed, contains('Location permission permanently denied.'));

    // Clean up the mock.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, null);
  });
  test('getUserLocation returns LatLng for granted permission', () async {
    // Mock the Geolocator methods.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, (
      call,
    ) async {
      if (call.method == 'isLocationServiceEnabled') return true;
      if (call.method == 'checkPermission') {
        return LocationPermission.denied.index;
      }
      if (call.method == 'requestPermission') {
        return LocationPermission.always.index;
      }
      if (call.method == 'getCurrentPosition') {
        return {
          'latitude': 10.0,
          'longitude': 20.0,
          'accuracy': 1.0,
          'altitude': 1.0,
          'heading': 1.0,
          'speed': 1.0,
          'speed_accuracy': 1.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
      return null;
    });

    final fetcher = LocationFetcher();
    final loc = await fetcher.getUserLocation();

    expect(loc?.latitude, 10);
    expect(loc?.longitude, 20);

    // Clean up the mock.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(geolocatorChannel, null);
  });
}
