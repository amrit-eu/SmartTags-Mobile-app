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
    this.edgeStartMaxY = 120,
  });

  /// Called when the pull exceeds the trigger distance.
  final Future<void> Function() onRefresh;

  /// Content that slides down together (header + map, etc.).
  final Widget child;

  /// When false, drag tracking is disabled.
  final bool enabled;

  /// Pull may start when the pointer is within this Y range from the top
  /// of this widget (covers the header, and optionally a search bar).
  final double edgeStartMaxY;

  @override
  ConsumerState<MapPullToRefresh> createState() => _MapPullToRefreshState();
}

class _MapPullToRefreshState extends ConsumerState<MapPullToRefresh> {
  /// Pull distance that triggers refresh (arrow fully revealed).
  static const double _triggerDistance = 48;

  /// Full [PlatformsLoadingBanner] height once refresh starts.
  static const double _bannerHeight = 44;

  /// How far content may rubber-band past the trigger for a satisfying overscroll.
  static const double _maxDrag = 180;

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

  /// Finger travel → visual offset, with extra resistance past the trigger.
  double _visualOffsetForFinger(double dy) {
    const resistance = 0.55;
    final raw = dy * resistance;
    if (raw <= _triggerDistance) {
      return raw;
    }
    // Past trigger: keep moving, but slow down (rubber band).
    final overflow = raw - _triggerDistance;
    final eased = _triggerDistance + overflow * 0.45;
    return eased.clamp(0.0, _maxDrag);
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
    // Start from the header / top band so normal scrolling stays smooth.
    if (event.localPosition.dy > widget.edgeStartMaxY) {
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

    final next = _visualOffsetForFinger(dy);
    if (next != _dragOffset) {
      setState(() => _dragOffset = next);
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

    return Center(
      child: Transform.rotate(
        angle: angle,
        child: Icon(
          Icons.refresh,
          size: 28,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset / _triggerDistance).clamp(0.0, 2.5);
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
          if (_refreshing)
            PlatformsLoadingBanner(message: loadingMessage)
          else if (_dragOffset > 0.5)
            SizedBox(
              height: _dragOffset,
              child: IgnorePointer(
                child: _buildPullArrow(context, progress),
              ),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
