import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/helpers/coordinate_format.dart';

void main() {
  test('formatLatLng uses hemisphere suffixes', () {
    expect(
      formatLatLng(const LatLng(48.29, -4.968)),
      '48.290°N, 4.968°W',
    );
    expect(
      formatLatLng(const LatLng(-33.815, 149.765)),
      '33.815°S, 149.765°E',
    );
  });

  test('formatLatitude and formatLongitude', () {
    expect(formatLatitude(45.5), '45.500°N');
    expect(formatLongitude(-5.5), '5.500°W');
  });
}
