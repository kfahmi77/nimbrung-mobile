import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/notifiers/app_auth_notifier.dart';
import '../screens/login/login_page.dart';

/// Root app widget that handles authentication-based routing
class AuthApp extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState state;

  const AuthApp({Key? key, required this.child, required this.state})
    : super(key: key);

  @override
  ConsumerState<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends ConsumerState<AuthApp> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appAuthNotifierProvider.notifier).checkAuthenticationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(appAuthNotifierProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildContent(authState),
    );
  }

  Widget _buildContent(AppAuthState authState) {
    switch (authState.runtimeType) {
      case AppAuthInitial:
      case AppAuthLoading:
        return const _LoadingScreen();

      case AppAuthAuthenticated:
        // User is authenticated, show the requested page or redirect to home if on auth pages
        final currentLocation = widget.state.uri.toString();
        if (_isAuthPage(currentLocation)) {
          // If user is on login/register page but authenticated, redirect to home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/home');
            }
          });
          return const _LoadingScreen();
        }
        return widget.child;

      case AppAuthUnauthenticated:
        // User is not authenticated, show login page or requested auth page
        final currentLocation = widget.state.uri.toString();
        if (_isAuthPage(currentLocation)) {
          return widget.child;
        } else {
          // Redirect to login if trying to access protected pages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/');
            }
          });
          return const LoginPage();
        }

      case AppAuthError:
        final errorState = authState as AppAuthError;
        return _ErrorScreen(
          message: errorState.message,
          onRetry: () {
            ref
                .read(appAuthNotifierProvider.notifier)
                .checkAuthenticationStatus();
          },
        );

      default:
        return const _LoadingScreen();
    }
  }

  bool _isAuthPage(String location) {
    return location == '/' ||
        location.startsWith('/register') ||
        location.startsWith('/login');
  }
}

/// Loading screen widget
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen widget
class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorScreen({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
