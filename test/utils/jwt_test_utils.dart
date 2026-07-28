import 'dart:convert';

import 'package:smart_tags/models/auth_response.dart';
import 'package:smart_tags/models/user.dart';

import 'test_user.dart';

/// Helper to produce Base64URL (RFC 7515) without padding
String b64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

String encodeJsonNoPad(Map<String, dynamic> json) =>
    b64UrlNoPad(utf8.encode(jsonEncode(json)));

User testUser = createTestUser();

/// Builds a compact JWT with given header/payload json and a dummy signature.
/// Signature content doesn’t matter for these decoding helpers.
String buildJwt({
  required Map<String, dynamic> payload,
  Map<String, dynamic>? header,
  String signature = 'sig',
}) {
  final hdr = header ?? <String, dynamic>{'alg': 'none', 'typ': 'JWT'};
  final headerPart = encodeJsonNoPad(hdr);
  final payloadPart = encodeJsonNoPad(payload);
  final signaturePart = b64UrlNoPad(utf8.encode(signature));
  return '$headerPart.$payloadPart.$signaturePart';
}

Map<String, dynamic> buildAuthResponse({
  bool success = true,
  String? accessTokenRs256,
  String refreshToken = 'mockRefreshToken',
  int refreshExpiresIn = 864000,
  int expiresIn = 3600,
  User? contact,
}) {
  accessTokenRs256 ??= buildJwt(
    payload: const {
      'sub': 'joe.bloggs@test.com',
      'name': 'Joe Bloggs',
      'exp': 1767225600, // token expiry 01-Jan-2026 00:00:00
      'contactId': 123456,
      'roles': ['alert-editor'],
    },
  );
  contact ??= createTestUser();
  return AuthResponse(
      success: success,
      accessTokenRs256: accessTokenRs256,
      refreshToken: refreshToken,
      refreshExpiresIn: refreshExpiresIn,
      expiresIn: expiresIn,
      contact: contact
  ).toJson();
}
