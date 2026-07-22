import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/models/platform.dart';

void main() {
  group('PlatformStatusPalette', () {
    test('maps CT-RST statuses to the AMRIT dashboard palette', () {
      expect(
        PlatformStatusPalette.resolve('REGISTERED').backgroundColor,
        const Color(0xFF64B5F6),
      );
      expect(
        PlatformStatusPalette.resolve('PROBABLE').backgroundColor,
        const Color(0xFFFBC02D),
      );
      expect(
        PlatformStatusPalette.resolve('CONFIRMED').backgroundColor,
        const Color(0xFF1976D2),
      );
      expect(
        PlatformStatusPalette.resolve('OPERATIONAL').backgroundColor,
        const Color(0xFF2E7D32),
      );
      expect(
        PlatformStatusPalette.resolve('INACTIVE').backgroundColor,
        const Color(0xFFC62828),
      );
      expect(
        PlatformStatusPalette.resolve('CLOSED').backgroundColor,
        const Color(0xFF212121),
      );
      expect(
        PlatformStatusPalette.resolve('UNKNOWN').backgroundColor,
        const Color(0xFF757575),
      );
    });

    test('uses correct text colours for badges', () {
      expect(PlatformStatusPalette.resolve('REGISTERED').textColor, Colors.black);
      expect(PlatformStatusPalette.resolve('PROBABLE').textColor, Colors.black);
      expect(PlatformStatusPalette.resolve('CONFIRMED').textColor, Colors.white);
      expect(PlatformStatusPalette.resolve('OPERATIONAL').textColor, Colors.white);
    });

    test('supports legacy Active local database values', () {
      final style = PlatformStatusPalette.resolve('Active');
      expect(style.label, 'Operational');
      expect(style.backgroundColor, const Color(0xFF2E7D32));
    });

    test('falls back to unknown for unrecognised statuses', () {
      expect(
        PlatformStatusPalette.resolve('NOT_LISTED').label,
        PlatformStatusPalette.unknown.label,
      );
    });

    test('forStatus matches resolve for enum values', () {
      for (final status in PlatformStatus.values) {
        expect(
          PlatformStatusPalette.forStatus(status).label,
          PlatformStatusPalette.resolve(status.apiName).label,
        );
      }
    });
  });
}
