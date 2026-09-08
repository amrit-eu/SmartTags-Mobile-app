import 'package:latlong2/latlong.dart';

String _formatComponent(
  double value,
  String positiveHemisphere,
  String negativeHemisphere, {
  int fractionDigits = 3,
}) {
  final absolute = value.abs().toStringAsFixed(fractionDigits);
  final hemisphere = value >= 0 ? positiveHemisphere : negativeHemisphere;
  return '$absolute°$hemisphere';
}

/// Formats latitude for operator-facing UI (e.g. `48.290°N`).
String formatLatitude(double latitude, {int fractionDigits = 3}) {
  return _formatComponent(latitude, 'N', 'S', fractionDigits: fractionDigits);
}

/// Formats longitude for operator-facing UI (e.g. `4.968°W`).
String formatLongitude(double longitude, {int fractionDigits = 3}) {
  return _formatComponent(longitude, 'E', 'W', fractionDigits: fractionDigits);
}

/// Formats a [LatLng] for operator-facing UI (e.g. `48.290°N, 4.968°W`).
String formatLatLng(LatLng point, {int fractionDigits = 3}) {
  return '${formatLatitude(point.latitude, fractionDigits: fractionDigits)}, '
      '${formatLongitude(point.longitude, fractionDigits: fractionDigits)}';
}
