import 'package:flutter/material.dart';
import 'package:smart_tags/screens/operation_record_screen.dart' show OperationSubmitResult;

/// Opens the deploy/recover form with a light fade. Reverse is shorter so
/// returning to platform detail feels quick rather than a heavy slide.
Route<OperationSubmitResult> operationRecordRoute(Widget child) {
  return PageRouteBuilder<OperationSubmitResult>(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
