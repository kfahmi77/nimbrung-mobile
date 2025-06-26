import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/register_dto.dart';
import '../models/user_model.dart';
import '../models/preference_model.dart';
import '../models/profile_update_dto.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

// Provider untuk AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// State untuk registrasi
class RegisterState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;
  final UserModel? user;

  const RegisterState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.user,
  });

  RegisterState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
    UserModel? user,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
      user: user ?? this.user,
    );
  }
}

// Notifier untuk registrasi
class RegisterNotifier extends StateNotifier<RegisterState> {
  final AuthService _authService;

  RegisterNotifier(this._authService) : super(const RegisterState());

  Future<void> register(RegisterRequest request) async {
    AppLogger.info(
      'Starting registration process in provider',
      tag: 'RegisterNotifier',
    );

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final response = await _authService.register(request);

      if (response.success) {
        AppLogger.info(
          'Registration successful in provider',
          tag: 'RegisterNotifier',
        );
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: response.message,
        );
      } else {
        AppLogger.warning(
          'Registration failed in provider: ${response.message}',
          tag: 'RegisterNotifier',
        );
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: response.message,
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error in registration provider',
        tag: 'RegisterNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Terjadi kesalahan yang tidak terduga.',
      );
    }
  }

  void clearState() {
    AppLogger.debug('Clearing registration state', tag: 'RegisterNotifier');
    state = const RegisterState();
  }
}

// Provider untuk register notifier
final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return RegisterNotifier(authService);
  },
);

// State untuk login
class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    UserModel? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

// Notifier untuk login
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(const LoginState());

  Future<void> login(String email, String password) async {
    AppLogger.info('Starting login process in provider', tag: 'LoginNotifier');

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.login(email, password);

      if (response.success) {
        AppLogger.info('Login successful in provider', tag: 'LoginNotifier');
        UserModel? user;
        if (response.userData != null) {
          try {
            AppLogger.debug('Parsing user data: ${response.userData}', tag: 'LoginNotifier');
            user = UserModel.fromJson(response.userData!);
          } catch (parseError) {
            AppLogger.error(
              'Failed to parse user data',
              tag: 'LoginNotifier',
              error: parseError,
            );
            // Continue without user model, or return error
            user = null;
          }
        }

        state = state.copyWith(isLoading: false, isSuccess: true, user: user);
      } else {
        AppLogger.warning(
          'Login failed in provider: ${response.message}',
          tag: 'LoginNotifier',
        );
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: response.message,
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error in login provider',
        tag: 'LoginNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Terjadi kesalahan yang tidak terduga.',
      );
    }
  }

  Future<void> logout() async {
    AppLogger.info('Starting logout process in provider', tag: 'LoginNotifier');
    await _authService.logout();
    state = const LoginState();
  }

  void clearState() {
    AppLogger.debug('Clearing login state', tag: 'LoginNotifier');
    state = const LoginState();
  }
}

// Provider untuk login notifier
final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginNotifier(authService);
});

// Provider untuk current user
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.getCurrentUser();

  if (currentUser != null) {
    AppLogger.debug('Getting current user profile', tag: 'CurrentUserProvider');
    return await authService.getUserProfile(currentUser.id);
  }

  return null;
});

// Provider untuk preferences
final preferencesProvider = FutureProvider<List<PreferenceModel>>((ref) async {
  AppLogger.debug('Getting preferences', tag: 'PreferencesProvider');
  final authService = ref.watch(authServiceProvider);
  return await authService.getPreferences();
});

// Provider untuk auth state (logged in atau tidak)
final authStateProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  final isLoggedIn = authService.isLoggedIn();
  AppLogger.debug('Auth state checked: $isLoggedIn', tag: 'AuthStateProvider');
  return isLoggedIn;
});

// State untuk pembaruan profil
class ProfileUpdateState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;
  final UserModel? user;

  const ProfileUpdateState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.user,
  });

  ProfileUpdateState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
    UserModel? user,
  }) {
    return ProfileUpdateState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
      user: user ?? this.user,
    );
  }
}

// Notifier untuk pembaruan profil
class ProfileUpdateNotifier extends StateNotifier<ProfileUpdateState> {
  final AuthService _authService;

  ProfileUpdateNotifier(this._authService) : super(const ProfileUpdateState());

  Future<void> updateProfile(
    String userId,
    ProfileUpdateRequest request,
  ) async {
    AppLogger.info(
      'Starting profile update process in provider',
      tag: 'ProfileUpdateNotifier',
    );

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.updateProfile(userId, request);

      if (response.isSuccess) {
        AppLogger.info(
          'Profile update successful in provider',
          tag: 'ProfileUpdateNotifier',
        );
        UserModel? user;
        if (response.userData != null) {
          user = UserModel.fromJson(response.userData!);
        }

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          successMessage: response.message,
          user: user,
        );
      } else {
        AppLogger.warning(
          'Profile update failed in provider: ${response.message}',
          tag: 'ProfileUpdateNotifier',
        );
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: response.message,
        );
      }
    } catch (e) {
      AppLogger.error(
        'Unexpected error in profile update provider',
        tag: 'ProfileUpdateNotifier',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Terjadi kesalahan yang tidak terduga.',
      );
    }
  }

  void clearState() {
    AppLogger.debug(
      'Clearing profile update state',
      tag: 'ProfileUpdateNotifier',
    );
    state = const ProfileUpdateState();
  }
}

// Provider untuk profile update notifier
final profileUpdateProvider =
    StateNotifierProvider<ProfileUpdateNotifier, ProfileUpdateState>((ref) {
      final authService = ref.watch(authServiceProvider);
      return ProfileUpdateNotifier(authService);
    });
