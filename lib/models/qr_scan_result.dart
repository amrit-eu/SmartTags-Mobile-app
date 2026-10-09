/// Result returned by the scanner when opened for platform pairing.
class QrScanResult {
  /// Creates a result containing the decoded OceanOPS QR reference.
  const QrScanResult.code(String code) : qrCode = code, errorMessage = null;

  /// Creates a result describing a failed scan.
  const QrScanResult.error(String message) : qrCode = null, errorMessage = message;

  /// QR reference extracted from the scanned tracking URL.
  final String? qrCode;

  /// User-facing error, when scanning failed.
  final String? errorMessage;
}
