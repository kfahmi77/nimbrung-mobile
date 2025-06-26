import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/register_dto.dart';
import '../models/user_model.dart';
import '../models/preference_model.dart';
import '../models/profile_update_dto.dart';
import '../utils/logger.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.instance;

  /// Register user dengan Supabase Auth dan insert ke table users
  Future<RegisterResponse> register(RegisterRequest request) async {
    AppLogger.info('Starting user registration', tag: 'AuthService');
    AppLogger.debug(
      'Registration request for email: ${request.email}',
      tag: 'AuthService',
    );

    try {
      // 1. Create user dengan Supabase Auth
      AppLogger.debug('Creating user with Supabase Auth', tag: 'AuthService');
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: request.email,
        password: request.password,
      );

      if (authResponse.user == null) {
        AppLogger.error('Auth response user is null', tag: 'AuthService');
        return RegisterResponse.failure(
          message: 'Gagal membuat akun. Silakan coba lagi.',
        );
      }

      final String userId = authResponse.user!.id;
      AppLogger.info(
        'User created successfully with ID: $userId',
        tag: 'AuthService',
      );

      // Wait a moment to ensure auth session is properly established
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Insert ke table users dengan data tambahan
      final userData = request.toJson();
      userData.remove('password'); // Hapus password dari data user
      userData.remove(
        'preference_id',
      ); // Explicitly remove preference_id during initial registration
      userData['id'] = userId; // Gunakan user ID dari Supabase Auth
      userData['preference_id'] =
          null; // Explicitly set preference_id to null for initial registration

      // Log the data being inserted for debugging
      AppLogger.debug(
        'User data to be inserted: $userData',
        tag: 'AuthService',
      );

      AppLogger.debug('Inserting user data to users table', tag: 'AuthService');
      try {
        final response =
            await _supabase
                .from(SupabaseConfig.usersTable)
                .insert(userData)
                .select()
                .single();

        AppLogger.info(
          'User registration completed successfully',
          tag: 'AuthService',
        );
        return RegisterResponse.success(
          message: 'Registrasi berhasil! Silakan cek email untuk verifikasi.',
          userId: userId,
          userData: response,
        );
      } catch (e) {
        AppLogger.error(
          'Failed to insert user data',
          tag: 'AuthService',
          error: e,
        );

        // Note: User is created in Supabase Auth but data insert failed
        // The user will need to complete registration on next login attempt
        AppLogger.warning(
          'User created in auth but profile data insert failed - user will need to complete profile',
          tag: 'AuthService',
        );

        if (e is PostgrestException) {
          AppLogger.error(
            'Database error during registration',
            tag: 'AuthService',
            error: e,
          );
          return RegisterResponse.failure(message: e.userFriendlyMessage);
        }

        return RegisterResponse.failure(
          message: 'Gagal menyimpan data pengguna. Silakan coba lagi.',
        );
      }
    } on AuthException catch (e) {
      AppLogger.error(
        'Auth exception during registration',
        tag: 'AuthService',
        error: e,
      );
      return RegisterResponse.failure(message: _getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error(
        'Unexpected error during registration',
        tag: 'AuthService',
        error: e,
      );
      return RegisterResponse.failure(
        message: 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
      );
    }
  }

  /// Login user
  Future<RegisterResponse> login(String email, String password) async {
    AppLogger.info('Starting user login', tag: 'AuthService');
    AppLogger.debug('Login attempt for email: $email', tag: 'AuthService');

    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        AppLogger.warning('Login failed - user is null', tag: 'AuthService');
        return RegisterResponse.failure(
          message: 'Login gagal. Silakan periksa email dan password.',
        );
      }

      AppLogger.info('User authenticated successfully', tag: 'AuthService');

      // Get user data from users table
      try {
        final userData =
            await _supabase
                .from(SupabaseConfig.usersTable)
                .select()
                .eq('id', response.user!.id)
                .single();

        AppLogger.debug(
          'Raw user data from database: $userData',
          tag: 'AuthService',
        );
        AppLogger.info('User data retrieved successfully', tag: 'AuthService');
        return RegisterResponse.success(
          message: 'Login berhasil!',
          userId: response.user!.id,
          userData: userData,
        );
      } catch (e) {
        AppLogger.error(
          'Failed to retrieve user data',
          tag: 'AuthService',
          error: e,
        );
        return RegisterResponse.failure(
          message: 'Gagal mengambil data pengguna. Silakan coba lagi.',
        );
      }
    } on AuthException catch (e) {
      AppLogger.error(
        'Auth exception during login',
        tag: 'AuthService',
        error: e,
      );
      return RegisterResponse.failure(message: _getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error(
        'Unexpected error during login',
        tag: 'AuthService',
        error: e,
      );
      return RegisterResponse.failure(
        message: 'Terjadi kesalahan saat login. Silakan coba lagi.',
      );
    }
  }

  /// Logout user
  Future<bool> logout() async {
    AppLogger.info('Starting user logout', tag: 'AuthService');
    try {
      await _supabase.auth.signOut();
      AppLogger.info('User logged out successfully', tag: 'AuthService');
      return true;
    } catch (e) {
      AppLogger.error('Failed to logout user', tag: 'AuthService', error: e);
      return false;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      AppLogger.debug('Current user found: ${user.email}', tag: 'AuthService');
    } else {
      AppLogger.debug('No current user found', tag: 'AuthService');
    }
    return user;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    final isLoggedIn = _supabase.auth.currentUser != null;
    AppLogger.debug('User logged in status: $isLoggedIn', tag: 'AuthService');
    return isLoggedIn;
  }

  /// Get user profile data
  Future<UserModel?> getUserProfile(String userId) async {
    AppLogger.debug('Getting user profile for ID: $userId', tag: 'AuthService');
    try {
      final response =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .select()
              .eq('id', userId)
              .single();

      AppLogger.info('User profile retrieved successfully', tag: 'AuthService');
      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.error(
        'Failed to get user profile',
        tag: 'AuthService',
        error: e,
      );
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    AppLogger.info('Updating user profile for ID: $userId', tag: 'AuthService');
    try {
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update(data)
          .eq('id', userId);
      AppLogger.info('User profile updated successfully', tag: 'AuthService');
      return true;
    } catch (e) {
      AppLogger.error(
        'Failed to update user profile',
        tag: 'AuthService',
        error: e,
      );
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    AppLogger.info(
      'Starting password reset for email: $email',
      tag: 'AuthService',
    );
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      AppLogger.info(
        'Password reset email sent successfully',
        tag: 'AuthService',
      );
      return true;
    } catch (e) {
      AppLogger.error(
        'Failed to send password reset email',
        tag: 'AuthService',
        error: e,
      );
      return false;
    }
  }

  /// Get all preferences
  Future<List<PreferenceModel>> getPreferences() async {
    AppLogger.debug('Getting all preferences', tag: 'AuthService');
    try {
      final response =
          await _supabase.from(SupabaseConfig.preferencesTable).select();

      AppLogger.info('Preferences retrieved successfully', tag: 'AuthService');
      return (response as List)
          .map((item) => PreferenceModel.fromJson(item))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to get preferences',
        tag: 'AuthService',
        error: e,
      );
      return [];
    }
  }

  /// Create new preference
  Future<PreferenceModel?> createPreference(String preferenceName) async {
    AppLogger.info(
      'Creating new preference: $preferenceName',
      tag: 'AuthService',
    );
    try {
      final response =
          await _supabase
              .from(SupabaseConfig.preferencesTable)
              .insert({'preferences_name': preferenceName})
              .select()
              .single();

      AppLogger.info('Preference created successfully', tag: 'AuthService');
      return PreferenceModel.fromJson(response);
    } catch (e) {
      AppLogger.error(
        'Failed to create preference',
        tag: 'AuthService',
        error: e,
      );
      return null;
    }
  }

  /// Get preference by name
  Future<String?> getPreferenceIdByName(String preferenceName) async {
    AppLogger.debug(
      'Getting preference ID for: $preferenceName',
      tag: 'AuthService',
    );
    try {
      final response =
          await _supabase
              .from('preferences')
              .select('id')
              .eq('preferences_name', preferenceName)
              .maybeSingle();

      if (response != null) {
        AppLogger.info(
          'Found preference ID for $preferenceName',
          tag: 'AuthService',
        );
        return response['id'] as String;
      }

      AppLogger.warning(
        'No preference found for name: $preferenceName',
        tag: 'AuthService',
      );
      return null;
    } catch (e) {
      AppLogger.error(
        'Failed to get preference by name',
        tag: 'AuthService',
        error: e,
      );
      return null;
    }
  }

  /// Complete user profile update
  Future<ProfileUpdateResponse> updateProfile(
    String userId,
    ProfileUpdateRequest request,
  ) async {
    AppLogger.info(
      'Starting profile update for user: $userId',
      tag: 'AuthService',
    );
    AppLogger.debug(
      'Profile update request for user: $userId',
      tag: 'AuthService',
    );

    try {
      final updateData = request.toJson();

      // If preferenceId is provided, use it directly
      if (request.preferenceId != null) {
        updateData['preference_id'] = request.preferenceId;
        AppLogger.debug(
          'Added preference_id: ${request.preferenceId}',
          tag: 'AuthService',
        );
      }

      AppLogger.debug('Updating user profile in database', tag: 'AuthService');
      final response =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .update(updateData)
              .eq('id', userId)
              .select()
              .single();

      AppLogger.info(
        'Profile updated successfully for user: $userId',
        tag: 'AuthService',
      );

      return ProfileUpdateResponse.success(
        message: 'Profil berhasil diperbarui!',
        userData: response,
      );
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error during profile update',
        tag: 'AuthService',
        error: e,
      );
      return ProfileUpdateResponse.failure(message: e.userFriendlyMessage);
    } catch (e) {
      AppLogger.error(
        'Unexpected error during profile update',
        tag: 'AuthService',
        error: e,
      );
      return ProfileUpdateResponse.failure(
        message:
            'Terjadi kesalahan saat memperbarui profil. Silakan coba lagi.',
      );
    }
  }

  String _getAuthErrorMessage(AuthException error) {
    AppLogger.debug(
      'Processing auth error: ${error.message}',
      tag: 'AuthService',
    );
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Email atau password salah.';
      case 'Email not confirmed':
        return 'Email belum dikonfirmasi. Silakan cek email Anda.';
      case 'User already registered':
        return 'Email sudah terdaftar. Silakan gunakan email lain.';
      case 'Password should be at least 6 characters':
        return 'Password minimal 6 karakter.';
      case 'Unable to validate email address: invalid format':
        return 'Format email tidak valid.';
      case 'signup is disabled':
        return 'Registrasi sedang tidak tersedia.';
      default:
        return 'Terjadi kesalahan autentikasi.';
    }
  }
}
