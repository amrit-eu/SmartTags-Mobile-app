/// Extracts the physical platform reference from an OceanOPS tracking sticker.
String? qrCodeReferenceFromUrl(String value) {
  final uri = Uri.tryParse(value);
  // Expected format: https://www.ocean-ops.org/tracking/?code=<reference>
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host != 'www.ocean-ops.org' ||
      (uri.path != '/tracking/' && uri.path != '/tracking') ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort) {
    return null;
  }

  final codes = uri.queryParametersAll['code'];
  if (codes == null || codes.length != 1 || codes.single.trim().isEmpty) {
    return null;
  }
  return codes.single;
}
