import 'package:flutter/material.dart';
import 'package:smart_tags/screens/catalogue_screen.dart';
import 'package:smart_tags/screens/map_screen.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';

/// Tab pages for widget tests using [MainNavigation] without map timers.
List<Widget> testMainNavigationPages() {
  return [
    const MapScreen(showMapSkeleton: false, reportMarkersPainted: false),
    const CatalogueScreen(),
    const QrScanScreen(),
  ];
}
