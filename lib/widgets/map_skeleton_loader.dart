import 'dart:async';

import 'package:flutter/material.dart';

/// Placeholder shown while ArcGIS ocean basemap tiles load on first open.
class MapSkeletonLoader extends StatefulWidget {
  /// Creates a [MapSkeletonLoader].
  const MapSkeletonLoader({super.key});

  @override
  State<MapSkeletonLoader> createState() => _MapSkeletonLoaderState();
}

class _MapSkeletonLoaderState extends State<MapSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    unawaited(_shimmerController.repeat());
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surfaceContainerLow;

    return ColoredBox(
      color: baseColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const columns = 4;
          const rows = 6;
          const gap = 3.0;
          final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
          final tileHeight = (constraints.maxHeight - gap * (rows - 1)) / rows;

          return AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return CustomPaint(
                painter: _MapSkeletonPainter(
                  columns: columns,
                  rows: rows,
                  gap: gap,
                  tileWidth: tileWidth,
                  tileHeight: tileHeight,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: _shimmerController.value,
                ),
                child: child,
              );
            },
            child: Center(
              child: Icon(
                Icons.map_outlined,
                size: 40,
                color: theme.colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapSkeletonPainter extends CustomPainter {
  _MapSkeletonPainter({
    required this.columns,
    required this.rows,
    required this.gap,
    required this.tileWidth,
    required this.tileHeight,
    required this.baseColor,
    required this.highlightColor,
    required this.shimmerValue,
  });

  final int columns;
  final int rows;
  final double gap;
  final double tileWidth;
  final double tileHeight;
  final Color baseColor;
  final Color highlightColor;
  final double shimmerValue;

  @override
  void paint(Canvas canvas, Size size) {
    final tilePaint = Paint()..color = baseColor.withValues(alpha: 0.85);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 + shimmerValue * 2, -0.4),
        end: Alignment(shimmerValue * 2, 0.4),
        colors: [
          baseColor.withValues(alpha: 0),
          highlightColor.withValues(alpha: 0.55),
          baseColor.withValues(alpha: 0),
        ],
        stops: const [0.25, 0.5, 0.75],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        final left = col * (tileWidth + gap);
        final top = row * (tileHeight + gap);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, tileWidth, tileHeight),
          const Radius.circular(4),
        );
        canvas
          ..drawRRect(rect, tilePaint)
          ..drawRRect(rect, shimmerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapSkeletonPainter oldDelegate) {
    return oldDelegate.shimmerValue != shimmerValue ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}
