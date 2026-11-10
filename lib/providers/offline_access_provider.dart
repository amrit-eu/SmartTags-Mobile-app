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
  const OfflineAccess(this.deadline, {this.accessTokenExpiry});

  /// The refresh token's expected expiry, recorded after the last successful
  /// login or token refresh. `null` when unknown, which counts as expired.
  final DateTime? deadline;

  /// When the current access token expires; `null` when unknown.
  final DateTime? accessTokenExpiry;

  /// Whether protected actions are no longer allowed at [now].
  bool isExpiredAt(DateTime now) {
    final deadline = this.deadline;
    return deadline == null || !now.isBefore(deadline);
  }

  /// Whether the session should be refreshed at [now], when online: once the
  /// access token has expired (or its expiry is unknown), or offline access has.
  bool isRefreshDueAt(DateTime now) {
    final accessTokenExpiry = this.accessTokenExpiry;
    return isExpiredAt(now) || accessTokenExpiry == null || !now.isBefore(accessTokenExpiry);
  }
}

/// The signed-in user's offline access, or `null` when no user is signed in.
///
/// Reloads when the user changes, when the auth service records or clears a
/// deadline (including silent token refreshes), and when the access token or
/// the deadline expires.
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
    DateTime? accessTokenExpiry;
    try {
      deadline = await authService.getOfflineAccessDeadline();
      accessTokenExpiry = await authService.getAccessTokenExpiry();
    } on Object catch (e) {
      // Unreadable deadline: fail closed, as for a missing one.
      debugPrint('Failed to read offline access deadline: $e');
    }

    // Rebuild when the access token expires, so the session is refreshed, and
    // when the deadline passes, so the UI drops to restricted access.
    for (final expiry in [accessTokenExpiry, deadline]) {
      if (expiry == null) continue;
      final remaining = expiry.difference(clock.now());
      if (!remaining.isNegative) {
        final timer = Timer(remaining, ref.invalidateSelf);
        ref.onDispose(timer.cancel);
      }
    }
    return OfflineAccess(deadline, accessTokenExpiry: accessTokenExpiry);
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

/// Whether a user is signed in and their session is due for a refresh (see
/// [OfflineAccess.isRefreshDueAt]).
final sessionRefreshDueProvider = Provider<bool>((ref) {
  final access = ref.watch(offlineAccessProvider).value;
  return access != null && access.isRefreshDueAt(clock.now());
});

/// Asks the server for fresh tokens, while online, as soon as the signed-in
/// user's access token has expired, or their offline access has (or has no
/// recorded deadline, e.g. a session created before deadlines were tracked).
/// Refreshing renews the refresh token, so the offline deadline moves forward.
/// Runs on start, when connectivity comes back and when a refresh becomes due.
/// Must be `ref.watch`'d at the app root.
final offlineAccessLifecycleProvider = Provider<void>((ref) {
  Future<void>? ongoing;

  Future<void> renewIfDue() async {
    try {
      if (!isDeviceOnline(ref.read(checkConnectionProvider).value)) return;
      final access = await ref.read(offlineAccessProvider.future);
      if (access == null || !access.isRefreshDueAt(clock.now())) return;
      await ref.read(authProvider.notifier).renewExpiredSession();
    } on Object catch (e) {
      // e.g. secure storage failure: stay restricted, retry on the next trigger.
      debugPrint('Offline access renewal failed: $e');
    }
  }

  void renew() {
    if (ongoing != null) return;
    ongoing = renewIfDue().whenComplete(() => ongoing = null);
  }

  ref
    ..listen(checkConnectionProvider.select((async) => async.value), (previous, next) {
      if (!isDeviceOnline(previous) && isDeviceOnline(next)) renew();
    })
    ..listen(sessionRefreshDueProvider, (previous, next) {
      if (next && previous != true) renew();
    }, fireImmediately: true);
});
