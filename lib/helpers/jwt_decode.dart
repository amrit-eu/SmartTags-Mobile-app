import 'dart:convert';

/// Splits a JWT into header, payload, and signature.
/// Returns the payload part (or null if invalid).
String? _extractPayload(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) {
    return null; // Invalid JWT format
  }
  return parts[1]; // Payload is the second part
}

/// Decodes a base64url-encoded payload to a JSON string.
String? _decodePayload(String encodedPayload) {
  try {
    final base64Decoder = base64.decoder;
    final data = base64.normalize(encodedPayload);
    final payloadBytes = base64Decoder.convert(data);
    // Convert bytes to UTF-8 string
    return utf8.decode(payloadBytes);
  } on FormatException catch (e) {
    print('Decoding failed: $e');
    return null;
  }
}

/// Parses a JSON payload string into a Map of claims.
Map<String, dynamic>? _parseClaims(String jsonPayload) {
  try {
    return jsonDecode(jsonPayload) as Map<String, dynamic>;
  } on FormatException catch (e) {
    print('JSON parsing failed: $e');
    return null;
  }
}

/// Returns a map of decoded claims from a JWT
Map<String, dynamic>? decodeJwtClaims(String jwt) {
  try {
    final payload = _extractPayload(jwt);
    if (payload == null) {
      throw const FormatException('Invalid JWT format (expected 3 parts)');
    }

    final jsonPayload = _decodePayload(payload);
    if (jsonPayload == null) {
      throw const FormatException('Failed to decode payload');
    }

    return _parseClaims(jsonPayload);
  } on FormatException catch (e) {
    print('Error decoding JWT: $e');
    return null;
  }
}
