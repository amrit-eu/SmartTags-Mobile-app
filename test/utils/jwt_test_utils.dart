import 'dart:convert';

/// Helper to produce Base64URL (RFC 7515) without padding
String b64UrlNoPad(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

String encodeJsonNoPad(Map<String, dynamic> json) =>
    b64UrlNoPad(utf8.encode(jsonEncode(json)));

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
