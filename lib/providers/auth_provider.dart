import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/error_notification_provider.dart';
import 'package:smart_tags/services/auth_service.dart';

/// Riverpod provider exposing an [AuthService] instance.
/// Use this provider to access authentication API via the [AuthNotifier].
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// A Riverpod [AsyncNotifier] managing authentication state.
///
/// Tracks the currently authenticated [UserProfile] or `null` if logged out.
/// Provides methods for logging in and out. The state is automatically
/// updated to [AsyncLoading], [AsyncData], or [AsyncError].
final authProvider = AsyncNotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);

/// Notifier that manages authentication state.
///
/// - [login] updates state to [AsyncLoading] and attempts to authenticate
///   via [AuthService].
/// - [logout] sets the state to `null`.
class AuthNotifier extends AsyncNotifier<UserProfile?> {

  late final AuthService _authService;

  @override
  Future<UserProfile?> build() async {
    _authService = ref.read(authServiceProvider);
    try {
      final result = await _callWithRefreshHandling<UserProfile?>(
        () => _authService.getAuthenticatedUser(),
      );
      return result;
    } on RefreshException {
      return null;
    }
  }

  /// Logs in a user using [email] and [password].
  ///
  /// Updates the state to [AsyncLoading] while waiting.
  /// On success, sets state to [AsyncData] containing the [UserProfile].
  /// On failure, sets state to [AsyncError].
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _authService.login(
        email: email,
        password: password,
      );
    });
  }

  /// Logs out the current user.
  Future<void> logout() async {
    final previous = state;
    state = const AsyncLoading();

    try {
      await _authService.logout();
      state = const AsyncData(null);
    } on PlatformException catch (e, st) { // error deleting token from storage
      // Emit error first so UI can read it
      state = AsyncError<UserProfile?>(e, st);
      // Then restore previous user so UI stays logged in
      state = previous;
    } // catch other exception thrown if remote logout fails if/when we logout server side
  }

  /// Gets the current authenticated user. Used for testing.
  Future<void> getMe() => _callWithRefreshHandling(() => _authService.getMe());

  /// Forces token expiry and gets the current authenticated user. Used for testing token refresh.
  Future<void> getMeForcedRefresh() => _callWithRefreshHandling(() async {
    await _authService.forceTokenExpiry();
    await _authService.getMe();
  });

  /// Forces token expiry with a failed refresh. This should log the user out.
  Future<void> getMeFailedRefresh() => _callWithRefreshHandling(() async {
    await _authService.forceTokenExpiry();
    await _authService.forceInvalidRefreshToken();
    await _authService.getMe();
  });

  /// Helper to handle refresh exceptions consistently across all methods.
  void _handleRefreshException(RefreshException e) {
    ref.read(errorNotificationProvider.notifier).setError(
      '${e.message}: Please log in again.',
      type: 'session_expired',
    );
    state = const AsyncData(null);
  }

  void _handleTemporaryError(Object e) {
    ref.read(errorNotificationProvider.notifier).setError(
      'A temporary error occurred. Please try again later.',
      type: 'temporary_error',
    );
  }

  /// Wraps any async operation that might trigger a token refresh error.
  /// Automatically handles RefreshException and updates state.
  Future<T?> _callWithRefreshHandling<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on RefreshException catch (e) {
      // Token refresh failed - Notify user to login again.
      _handleRefreshException(e);
      return null;
    } on AuthException catch (e) {
      // This could be a temporary server error during refresh - notify user but keep them logged in with old token.
      _handleTemporaryError(e);
      return null;
    } on http.ClientException catch (e) {
      // This could be a temporary network error during refresh - notify user but keep them logged in with old token.
      _handleTemporaryError(e);
      return null;
    }
  }
}
