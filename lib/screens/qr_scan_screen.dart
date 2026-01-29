import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_tags/database/mappers/platform_mapper.dart';
import 'package:smart_tags/providers.dart';
import 'package:smart_tags/screens/platform_detail_screen.dart';

/// A screen that provides QR code scanning functionality.
class QrScanScreen extends ConsumerStatefulWidget {
  /// Creates a [QrScanScreen] widget.
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastFailedReference;

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == _lastFailedReference) {
        return;
      }
      if (code != null) {
        final reference = _extractReference(code);
        if (reference != null) {
          unawaited(_handleValidCode(reference));
        } else {
          setState(() => _lastFailedReference = code);
          _showMessage('Invalid QR Code format');
        }
        break; // Process only the first barcode
      }
    }
  }

  /// Extracts reference from OceanTags URL.
  /// Example: `https://www.ocean-ops.org/oceantags/RFHCZ3S` → `RFHCZ3S`
  String? _extractReference(String url) {
    const prefix = 'https://www.ocean-ops.org/oceantags/';
    if (url.startsWith(prefix)) {
      return url.substring(prefix.length);
    }
    return null;
  }

  Future<void> _handleValidCode(String reference) async {
    if (!mounted) return;
    if (reference == _lastFailedReference) {
      return;
    }    setState(() => _isProcessing = true);
    await _scannerController.stop();
    try {
      final platforms = await ref.read(platformByRefProvider(reference).future);
      if (platforms.isEmpty) {
        setState(() => _lastFailedReference = reference);
        _showMessage('No platforms found');
      } else {
        final platform = platforms.first;
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => PlatformDetailScreen(platform: platform.toDomain()),
          ),
        );
      }
    } catch (e, st) {
      setState(() => _lastFailedReference = reference);
      _showMessage('Error fetching platform');
      Error.throwWithStackTrace(e, st);
    } finally {
      if (mounted) { // Only restart scanner if widget is still active
        setState(() => _isProcessing = false);
        await _scannerController.start();
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () => setState(() => _lastFailedReference = null)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
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
          ),
          // Overlay with transparent scanning area
          Positioned.fill(
            child: CustomPaint(
              painter: _QrScannerOverlay(
                borderColor: Theme.of(context).colorScheme.primary,
              ),
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
