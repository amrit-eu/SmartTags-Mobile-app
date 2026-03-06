import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/screens/user_profile.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that allows a user to log in via OceanOps using their username and password.
class UserLoginScreen extends ConsumerStatefulWidget {
  /// Creates a [UserLoginScreen].
  const UserLoginScreen({super.key});

  @override
  ConsumerState<UserLoginScreen> createState() => _UserLoginState();
}

class _UserLoginState extends ConsumerState<UserLoginScreen> {
  AsyncValue<UserProfile?>? _authState;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    ref.listen(authProvider, (previous, next) async {
      _authState = next;
      await next.whenOrNull(
        data: (user) async {
          if (user != null) {
            // If user is not null, navigate to the user profile screen.
            await Navigator.of(context).pushReplacement(
                MaterialPageRoute<UserProfileScreen>(
                  builder: (BuildContext ctx) => UserProfileScreen(
                    user: user,
                  ),
                )
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
              Text(error.toString()),
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: TopNavigation(title: const Text('Login'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Header
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to your OceanOPS account',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Login Button
                  ElevatedButton(
                    key: const Key('logInButton'),
                    onPressed: isLoading ? null : () async {
                      final form = _formKey.currentState;
                      if (form == null || !form.validate()) {
                        return;
                      }
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                            await ref
                                .read(authProvider.notifier)
                                .login(email, password)
                                .then(
                                  (_) {
                                    final authState = _authState;
                                    if (!context.mounted) return;
                                    if (authState is AsyncData<UserProfile?> && authState.value != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login successful'),
                                        ),
                                      );
                                    }
                                  },
                                  onError: (Object err) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Login failed: $err')),
                                    );
                                  },
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Sign In',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
