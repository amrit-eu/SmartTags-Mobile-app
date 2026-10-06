import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/helpers/qr_code_reference.dart';

void main() {
  test('extracts the exact QR reference with other and encoded query values', () {
    expect(
      qrCodeReferenceFromUrl('https://www.ocean-ops.org/tracking/?source=sticker&code=AbC%2F123&x=1'),
      'AbC/123',
    );
  });

  test('rejects invalid URLs', () {
    for (final value in [
      'https://example.com/tracking/?code=ABC',
      'https://www.ocean-ops.org/oceantags/ABC',
      'https://www.ocean-ops.org/tracking/?code=',
      'https://www.ocean-ops.org/tracking/?code=%20',
      'https://www.ocean-ops.org/tracking/?code=ABC&code=DEF',
      'https://www.ocean-ops.org/tracking/?other=ABC',
      'https://www.ocean-ops.org/tracking-else/?code=ABC',
    ]) {
      expect(qrCodeReferenceFromUrl(value), isNull, reason: value);
    }
  });
}
