/// HTTP response headers from the Amrit Gateway bulk passport export.
abstract final class GatewayHeaders {
  /// Lowercase bulk export total (`X-Total-Count` on the wire).
  static const totalCount = 'x-total-count';
}
