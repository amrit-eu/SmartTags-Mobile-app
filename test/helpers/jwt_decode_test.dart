import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/helpers/jwt_decode.dart';
import '../utils/jwt_test_utils.dart';

void main() {
  group('JWT Decode', () {
    test('returns claims for a valid JWT', () {
      final jwt = buildJwt(
        payload: {
          'sub': 'joe.bloggs@test.com',
          'name': 'Joe Bloggs',
          'exp': 1767225600, // token expiry 01-Jan-2026 00:00:00
          'contactId': 123456
        },
      );

      final claims = decodeJwtClaims(jwt);

      expect(claims, isNotNull);
      expect(claims['sub'], 'joe.bloggs@test.com');
      expect(claims['name'],  'Joe Bloggs');
      expect(claims['exp'], 1767225600);
      expect(claims['contactId'], 123456);
    });

    test('throws when JWT does not have 3 parts', () {
        expect(() => decodeJwtClaims('a.b'), throwsA(isA<JwtDecodingException>()),);
        expect(() => decodeJwtClaims('a'), throwsA(isA<JwtDecodingException>()),);
        expect(() => decodeJwtClaims(''), throwsA(isA<JwtDecodingException>()),);
    });

    test('throws if unable to decode payload', () {
      // Make the payload contain invalid base64url characters
      final header = encodeJsonNoPad({'alg': 'none', 'typ': 'JWT'});
      const invalidPayload = '%%%'; // not valid base64url
      final sig = b64UrlNoPad(utf8.encode('sig'));

      final jwt = '$header.$invalidPayload.$sig';

      expect(() => decodeJwtClaims(jwt), throwsA(isA<JwtDecodingException>()),);
    });

    test('throws if payload decodes but is not valid UTF-8 JSON', () {
      // Build a payload that is valid base64url but decodes to non-JSON bytes.
      // For instance, raw bytes that don’t represent a JSON string.
      final header = encodeJsonNoPad({'alg': 'none', 'typ': 'JWT'});

      final nonJsonBytes = <int>[0x00, 0xFF, 0xFE, 0xFD, 0x7F, 0x10];
      final payloadPart = b64UrlNoPad(nonJsonBytes);

      final sig = b64UrlNoPad(utf8.encode('sig'));
      final jwt = '$header.$payloadPart.$sig';

      // _decodePayload will try utf8.decode; may throw/catch FormatException and return null.
      // Overall decodeJwtClaims should return null.
      expect(() => decodeJwtClaims(jwt), throwsA(isA<JwtDecodingException>()),);
    });

    test('throws if unable to parse claims', () {
      final header = encodeJsonNoPad({'alg': 'none', 'typ': 'JWT'});
      // A UTF-8 string that is not valid JSON (e.g. missing quotes/braces)
      const invalidJsonString = 'not-json-at-all';
      final payloadPart = b64UrlNoPad(utf8.encode(invalidJsonString));
      final sig = b64UrlNoPad(utf8.encode('sig'));
      final jwt = '$header.$payloadPart.$sig';

      expect(() => decodeJwtClaims(jwt), throwsA(isA<JwtDecodingException>()),);
    });
  });
}
