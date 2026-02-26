import 'dart:convert';

/// Exception thrown when JWT decoding fails.
class JwtDecodingException implements Exception {
  /// Creates a [JwtDecodingException] with the given [message].
  const JwtDecodingException(this.message);
  @override
  String toString() => 'JwtDecodingException: $message';

  /// The error message describing the authentication failure.
  final String message;
}

/// Splits a JWT into header, payload, and signature.
/// Returns the payload part (or null if invalid).
String _extractPayload(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) {
    throw const JwtDecodingException('Invalid JWT format (expected 3 parts)');
  }
  return parts[1]; // Payload is the second part
}

/// Decodes a base64url-encoded payload to a JSON string.
String _decodePayload(String encodedPayload) {
  try {
    final base64Decoder = base64.decoder;
    final data = base64.normalize(encodedPayload);
    final payloadBytes = base64Decoder.convert(data);
    // Convert bytes to UTF-8 string
    return utf8.decode(payloadBytes);
  } on FormatException catch (e) {
      throw JwtDecodingException('Failed to decode payload: $e');
  }
}

/// Parses a JSON payload string into a Map of claims.
Map<String, dynamic> _parseClaims(String jsonPayload) {
  try {
    return jsonDecode(jsonPayload) as Map<String, dynamic>;
  } on FormatException catch (e) {
    throw JwtDecodingException('JSON parsing failed: $e');
  }
}

/// Returns a map of decoded claims from a JWT
Map<String, dynamic> decodeJwtClaims(String jwt) {
  final payload = _extractPayload(jwt);
  final jsonPayload = _decodePayload(payload);
  return _parseClaims(jsonPayload);
}
