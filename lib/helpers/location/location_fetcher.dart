import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Class to handle fetching the location of a user.
class LocationFetcher {
  /// Ensures location services are on and the app has when-in-use permission.
  Future<bool> ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      debugPrint('Location permission denied.');
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied.');
      return false;
    }
    return true;
  }

  /// Fetches and returns the LatLng of the user.
  Future<LatLng?> getUserLocation() async {
    if (!await ensureLocationPermission()) {
      return null;
    }

    // Fetch location
    final position = await Geolocator.getCurrentPosition();
    debugPrint(
      'Location Found: ${position.latitude}, ${position.longitude}',
    );
    return LatLng(position.latitude, position.longitude);
  }
}
