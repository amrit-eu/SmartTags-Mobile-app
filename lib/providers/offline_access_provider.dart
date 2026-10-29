import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';

/// Shown wherever a protected action is refused because offline access expired.
const offlineAccessExpiredMessage =
    'Offline access has expired. Connect to the internet and log in again to record operations.';

/// How long the signed-in user may keep using their cached permissions
/// without reauthenticating: until the refresh token's expected expiry.
@immutable
class OfflineAccess {
  /// Creates an [OfflineAccess] ending at [deadline].
  const OfflineAccess(this.deadline);

  /// The refresh token's expected expiry, recorded after the last successful
  /// login or token refresh. `null` when unknown, which counts as expired.
  final DateTime? deadline;

  /// Whether protected actions are no longer allowed at [now].
  bool isExpiredAt(DateTime now) {
    final deadline = this.deadline;
    return deadline == null || !now.isBefore(deadline);
  }
}

/// The signed-in user's offline access, or `null` when no user is signed in.
///
/// Reloads when the user changes, when the auth service records or clears a
/// deadline (including silent token refreshes), and when the deadline passes.
final offlineAccessProvider = AsyncNotifierProvider<OfflineAccessNotifier, OfflineAccess?>(
  OfflineAccessNotifier.new,
);

/// Notifier backing [offlineAccessProvider].
class OfflineAccessNotifier extends AsyncNotifier<OfflineAccess?> {
  @override
  Future<OfflineAccess?> build() async {
    final userId = ref.watch(authProvider.select((async) => async.value?.id));
    if (userId == null) return null;

    final authService = ref.watch(authServiceProvider);
    final subscription = authService.offlineAccessDeadlineChanges.listen((_) => ref.invalidateSelf());
    ref.onDispose(subscription.cancel);

    DateTime? deadline;
    try {
      deadline = await authService.getOfflineAccessDeadline();
    } on Object catch (e) {
      // Unreadable deadline: fail closed, as for a missing one.
      debugPrint('Failed to read offline access deadline: $e');
    }

    if (deadline != null) {
      final remaining = deadline.difference(clock.now());
      if (!remaining.isNegative) {
        // Rebuild when the deadline passes so the UI drops to restricted access.
        final timer = Timer(remaining, ref.invalidateSelf);
        ref.onDispose(timer.cancel);
      }
    }
    return OfflineAccess(deadline);
  }
}

/// Whether a user is signed in but their offline access has expired, so only
/// non-restricted actions remain until they reauthenticate online.
///
/// `false` until the first load completes, to avoid flashing restricted UI
/// at start-up; code that must not act on stale access (e.g. queueing work)
/// should await [offlineAccessProvider] instead.
final offlineAccessExpiredProvider = Provider<bool>((ref) {
  final access = ref.watch(offlineAccessProvider).value;
  return access != null && access.isExpiredAt(clock.now());
});

/// Asks the server for fresh tokens, while online, whenever the signed-in
/// user's offline access has expired or has no recorded deadline (e.g. a
/// session created before deadlines were tracked). Runs on start, when
/// connectivity comes back and when access expires. Must be `ref.watch`'d at
/// the app root.
final offlineAccessLifecycleProvider = Provider<void>((ref) {
  Future<void>? ongoing;

  Future<void> renewIfExpired() async {
    try {
      if (!isDeviceOnline(ref.read(checkConnectionProvider).value)) return;
      final access = await ref.read(offlineAccessProvider.future);
      if (access == null || !access.isExpiredAt(clock.now())) return;
      await ref.read(authProvider.notifier).renewExpiredSession();
    } on Object catch (e) {
      // e.g. secure storage failure: stay restricted, retry on the next trigger.
      debugPrint('Offline access renewal failed: $e');
    }
  }

  void renew() {
    if (ongoing != null) return;
    ongoing = renewIfExpired().whenComplete(() => ongoing = null);
  }

  ref
    ..listen(checkConnectionProvider.select((async) => async.value), (previous, next) {
      if (!isDeviceOnline(previous) && isDeviceOnline(next)) renew();
    })
    ..listen(offlineAccessExpiredProvider, (previous, next) {
      if (next && previous != true) renew();
    }, fireImmediately: true);
});
