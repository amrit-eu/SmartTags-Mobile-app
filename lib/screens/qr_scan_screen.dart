import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_tags/helpers/qr_code_reference.dart';
import 'package:smart_tags/models/qr_scan_result.dart';
import 'package:smart_tags/providers/qr_passport_lookup_provider.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that provides QR code scanning functionality.
class QrScanScreen extends ConsumerStatefulWidget {
  /// Creates a [QrScanScreen] widget.
  const QrScanScreen({super.key, this.onValidCode}) : isPairing = false;

  /// Returns a [QrScanResult] to the calling platform details route.
  const QrScanScreen.pairing({super.key}) : onValidCode = null, isPairing = true;

  /// Selects the catalogue tab after a valid QR scan.
  final VoidCallback? onValidCode;

  /// Whether a scan should return to platform details for pairing.
  final bool isPairing;

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _isProcessing = false;
  String? _lastInvalidCode;

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == _lastInvalidCode) {
        continue;
      }
      if (code != null) {
        final qrCode = qrCodeReferenceFromUrl(code);
        if (widget.isPairing) {
          _returnPairingResult(
            qrCode == null ? const QrScanResult.error('Invalid QR Code format') : QrScanResult.code(qrCode),
          );
          return;
        }
        if (qrCode != null) {
          _messengerKey.currentState?.clearSnackBars();
          setState(() => _isProcessing = true);
          unawaited(_handleValidCode(qrCode));
        } else {
          setState(() => _lastInvalidCode = code);
          _showMessage('Invalid QR Code format');
        }
        break; // Process only the first barcode
      }
    }
  }

  void _returnPairingResult(QrScanResult result) {
    if (!mounted || _isProcessing) return;
    setState(() => _isProcessing = true);
    Navigator.of(context).pop(result);
  }

  Widget _pairingCameraError(BuildContext context, MobileScannerException error) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'Camera permission is required to pair a QR code.'
        : 'Unable to open the QR scanner. Please try again.';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _returnPairingResult(QrScanResult.error(message));
    });
    return Center(child: Text(message));
  }

  Future<void> _handleValidCode(String qrCode) async {
    if (!mounted) return;
    try {
      unawaited(ref.read(qrPassportLookupProvider.notifier).lookup(qrCode));
      widget.onValidCode?.call();
      await _scannerController.stop();
    } on Object {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showMessage('Unable to start scanner lookup');
      }
    }
  }

  void _showMessage(String message) {
    final messenger = _messengerKey.currentState;
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        persist: true,
        dismissDirection: DismissDirection.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: TopNavigation(
          title: const Text('Scan QR Code'),
          leading: widget.isPairing ? const BackButton() : null,
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _scannerController,
                builder: (context, state, child) {
                  return Icon(
                    state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  );
                },
              ),
              onPressed: _scannerController.toggleTorch,
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _scannerController.switchCamera,
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
              errorBuilder: widget.isPairing ? _pairingCameraError : null,
            ),
            // Overlay with transparent scanning area
            Positioned.fill(
              child: CustomPaint(
                painter: _QrScannerOverlay(borderColor: Theme.of(context).colorScheme.primary),
              ),
            ),
            // Scanning indicator
            if (_isProcessing)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw a blurred overlay with a transparent scanning square.
class _QrScannerOverlay extends CustomPainter {
  _QrScannerOverlay({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(179);
    final cutoutSize = size.width * 0.7;
    final cutoutOffset = Offset(
      (size.width - cutoutSize) / 2,
      (size.height - cutoutSize) / 3,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(
        Rect.fromLTWH(
          cutoutOffset.dx,
          cutoutOffset.dy,
          cutoutSize,
          cutoutSize,
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw border around scanning area
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(
      Rect.fromLTWH(cutoutOffset.dx, cutoutOffset.dy, cutoutSize, cutoutSize),
      borderPaint,
    );

    // Draw corner accents
    const cornerLength = 30.0;
    const cornerWidth = 4.0;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      cutoutOffset.dx,
      cutoutOffset.dy,
      cutoutSize,
      cutoutSize,
    );

    // Top-left corner
    canvas
      ..drawLine(
        rect.topLeft,
        rect.topLeft + const Offset(cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        rect.topLeft,
        rect.topLeft + const Offset(0, cornerLength),
        cornerPaint,
      )
      // Top-right corner
      ..drawLine(
        rect.topRight,
        rect.topRight + const Offset(-cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        rect.topRight,
        rect.topRight + const Offset(0, cornerLength),
        cornerPaint,
      )
      // Bottom-left corner
      ..drawLine(
        rect.bottomLeft,
        rect.bottomLeft + const Offset(cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        rect.bottomLeft,
        rect.bottomLeft + const Offset(0, -cornerLength),
        cornerPaint,
      )
      // Bottom-right corner
      ..drawLine(
        rect.bottomRight,
        rect.bottomRight + const Offset(-cornerLength, 0),
        cornerPaint,
      )
      ..drawLine(
        rect.bottomRight,
        rect.bottomRight + const Offset(0, -cornerLength),
        cornerPaint,
      );
  }

  @override
  bool shouldRepaint(_QrScannerOverlay oldDelegate) => borderColor != oldDelegate.borderColor;
}
