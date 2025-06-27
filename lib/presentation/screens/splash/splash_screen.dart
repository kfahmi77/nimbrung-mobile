import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../features/auth/presentation/notifiers/app_auth_notifier.dart';

/// Splash screen that handles authentication check and routing
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Add small delay for better UX
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      await ref
          .read(appAuthNotifierProvider.notifier)
          .checkAuthenticationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppAuthState>(appAuthNotifierProvider, (previous, next) {
      if (next is AppAuthAuthenticated) {
        // User is authenticated, navigate to home
        context.go('/home');
      } else if (next is AppAuthUnauthenticated) {
        // User is not authenticated, navigate to login
        context.go('/login');
      } else if (next is AppAuthError) {
        // Show error snackbar but stay on splash
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.message}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _checkAuthentication,
            ),
          ),
        );
      }
    });

    final authState = ref.watch(appAuthNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.book_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            Text(
              'Nimbrung',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Platform Diskusi Buku',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            if (authState is AppAuthLoading || authState is AppAuthInitial)
              Column(
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

            // Error state
            if (authState is AppAuthError)
              Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkAuthentication,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
