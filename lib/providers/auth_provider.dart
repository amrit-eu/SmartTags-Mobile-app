import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/services/auth_service.dart';

/// Riverpod provider exposing an [AuthService] instance.
/// Use this provider to access authentication API via the [AuthNotifier].
final authServiceProvider = Provider<AuthService>((ref) {
  final client = http.Client();
  return AuthService(client);
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
    return null;
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
  ///
  /// Sets the state to `AsyncData(null)` to represent a logged-out state.
  void logout() {
    state = const AsyncData(null);
  }
}
