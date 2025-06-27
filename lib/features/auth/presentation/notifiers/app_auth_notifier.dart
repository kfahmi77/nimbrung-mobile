import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/logout.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';

/// Authentication state for the entire app
abstract class AppAuthState {
  const AppAuthState();
}

/// Initial state - checking authentication
class AppAuthInitial extends AppAuthState {
  const AppAuthInitial();
}

/// Loading state - verifying token/user
class AppAuthLoading extends AppAuthState {
  const AppAuthLoading();
}

/// User is authenticated and logged in
class AppAuthAuthenticated extends AppAuthState {
  final User user;

  const AppAuthAuthenticated({required this.user});
}

/// User is not authenticated - need to login
class AppAuthUnauthenticated extends AppAuthState {
  const AppAuthUnauthenticated();
}

/// Error state
class AppAuthError extends AppAuthState {
  final String message;

  const AppAuthError({required this.message});
}

/// App-wide authentication notifier
class AppAuthNotifier extends StateNotifier<AppAuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AppAuthNotifier({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AppAuthInitial());

  /// Check authentication status on app startup
  Future<void> checkAuthenticationStatus() async {
    try {
      AppLogger.info('Checking authentication status', tag: 'AppAuthNotifier');

      state = const AppAuthLoading();

      final result = await _getCurrentUserUseCase(NoParams());

      result.fold(
        (failure) {
          AppLogger.info(
            'User not authenticated: ${failure.message}',
            tag: 'AppAuthNotifier',
          );
          state = const AppAuthUnauthenticated();
        },
        (user) {
          if (user != null) {
            AppLogger.info(
              'User authenticated: ${user.email}',
              tag: 'AppAuthNotifier',
            );
            state = AppAuthAuthenticated(user: user);
          } else {
            AppLogger.info('No current user found', tag: 'AppAuthNotifier');
            state = const AppAuthUnauthenticated();
          }
        },
      );
    } catch (e) {
      AppLogger.error(
        'Error checking authentication: $e',
        tag: 'AppAuthNotifier',
        error: e,
      );
      state = AppAuthError(message: e.toString());
    }
  }

  /// Set user as authenticated (called after successful login/register)
  void setAuthenticated(User user) {
    AppLogger.info(
      'Setting user as authenticated: ${user.email}',
      tag: 'AppAuthNotifier',
    );
    state = AppAuthAuthenticated(user: user);
  }

  /// Set user as unauthenticated (called after logout)
  Future<void> logout() async {
    try {
      AppLogger.info('Logging out user', tag: 'AppAuthNotifier');

      state = const AppAuthLoading();

      final result = await _logoutUseCase(NoParams());

      result.fold(
        (failure) {
          AppLogger.error(
            'Logout failed: ${failure.message}',
            tag: 'AppAuthNotifier',
          );
          // Even if logout fails, clear local state
          state = const AppAuthUnauthenticated();
        },
        (_) {
          AppLogger.info(
            'User logged out successfully',
            tag: 'AppAuthNotifier',
          );
          state = const AppAuthUnauthenticated();
        },
      );
    } catch (e) {
      AppLogger.error(
        'Error during logout: $e',
        tag: 'AppAuthNotifier',
        error: e,
      );
      // Even if error occurs, clear local state
      state = const AppAuthUnauthenticated();
    }
  }

  /// Clear error state
  void clearError() {
    if (state is AppAuthError) {
      state = const AppAuthUnauthenticated();
    }
  }

  /// Get current user if authenticated
  User? get currentUser {
    final currentState = state;
    if (currentState is AppAuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return state is AppAuthAuthenticated;
  }

  /// Check if authentication is loading
  bool get isLoading {
    return state is AppAuthLoading;
  }
}
