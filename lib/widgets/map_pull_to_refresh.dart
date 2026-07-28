import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';
import 'package:smart_tags/widgets/platforms_loading_banner.dart';

/// Instagram / Gmail-style pull-to-refresh for non-scrollable content.
///
/// - While pulling: circular refresh arrow (fetch not started yet)
/// - After trigger: shared [PlatformsLoadingBanner] with download/save phases
///
/// Uses a [Listener] (not a [ScrollView] / [CustomScrollView]) so map rendering
/// is never nested in a scrollable — avoiding `debugFrameWasSentToEngine` floods.
class MapPullToRefresh extends ConsumerStatefulWidget {
  /// Creates a [MapPullToRefresh].
  const MapPullToRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.enabled = true,
  });

  /// Called when the pull exceeds the trigger distance.
  final Future<void> Function() onRefresh;

  /// Content that slides down together (header + map, etc.).
  final Widget child;

  /// When false, drag tracking is disabled.
  final bool enabled;

  @override
  ConsumerState<MapPullToRefresh> createState() => _MapPullToRefreshState();
}

class _MapPullToRefreshState extends ConsumerState<MapPullToRefresh> {
  /// Slot height while dragging (arrow only).
  static const double _pullSlotHeight = 48;
  /// Full [PlatformsLoadingBanner] height once refresh starts.
  static const double _bannerHeight = 44;
  static const double _triggerDistance = _pullSlotHeight;
  static const double _maxDrag = 88;
  /// Allow starting the pull from the header / top of the map.
  static const double _edgeStartMaxY = 120;

  double _dragOffset = 0;
  var _refreshing = false;
  var _tracking = false;
  int? _pointer;
  Offset? _start;

  void _clearPointer() {
    _tracking = false;
    _pointer = null;
    _start = null;
  }

  void _snapBack() {
    setState(() {
      _dragOffset = 0;
      _clearPointer();
    });
  }

  Future<void> _triggerRefresh() async {
    if (_refreshing) {
      return;
    }
    setState(() {
      _refreshing = true;
      _dragOffset = _bannerHeight;
      _clearPointer();
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _dragOffset = 0;
        });
      }
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || _refreshing) {
      return;
    }
    // Start from the header / top map band so normal map pans stay smooth.
    if (event.localPosition.dy > _edgeStartMaxY) {
      return;
    }
    _pointer = event.pointer;
    _start = event.localPosition;
    _tracking = true;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_tracking || event.pointer != _pointer || _start == null) {
      return;
    }

    final delta = event.localPosition - _start!;
    final dy = delta.dy;
    final dx = delta.dx.abs();

    // Require a clearly vertical downward pull.
    if (dy <= 0 || dy < dx * 1.35) {
      if (_dragOffset > 0) {
        setState(() => _dragOffset = 0);
      }
      return;
    }

    final damped = (dy * 0.55).clamp(0.0, _maxDrag);
    if (damped != _dragOffset) {
      setState(() => _dragOffset = damped);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    if (_dragOffset >= _triggerDistance) {
      unawaited(_triggerRefresh());
    } else {
      _snapBack();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    _snapBack();
  }

  Widget _buildPullArrow(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final angle = progress * 2 * math.pi;

    return SizedBox(
      height: _pullSlotHeight,
      child: Center(
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            Icons.refresh,
            size: 28,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset / _triggerDistance).clamp(0.0, 1.5);
    final revealHeight = _refreshing ? _bannerHeight : _dragOffset;
    final showChrome = revealHeight > 0.5;

    final slotHeight = _refreshing ? _bannerHeight : _pullSlotHeight;
    final heightFactor = (revealHeight / slotHeight).clamp(0.0, 1.0);

    final phase = ref.watch(platformsSyncPhaseProvider);
    final loadingMessage = phase.bannerMessage ?? 'Downloading platforms…';

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showChrome)
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: heightFactor,
                child: IgnorePointer(
                  child: _refreshing
                      ? PlatformsLoadingBanner(message: loadingMessage)
                      : _buildPullArrow(context, progress),
                ),
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
