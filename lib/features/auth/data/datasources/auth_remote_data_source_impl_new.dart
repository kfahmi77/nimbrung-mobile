import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/logger.dart';
import '../../../user/data/models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase = SupabaseConfig.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    AppLogger.info('Starting user login', tag: 'AuthRemoteDataSource');
    AppLogger.debug(
      'Login attempt for email: $email',
      tag: 'AuthRemoteDataSource',
    );

    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        AppLogger.warning(
          'Login failed - user is null',
          tag: 'AuthRemoteDataSource',
        );
        throw Exception('Login gagal. Silakan periksa email dan password.');
      }

      AppLogger.info(
        'User authenticated successfully',
        tag: 'AuthRemoteDataSource',
      );

      // Get user data from users table with preference name
      final userData =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .select('''
            *,
            preferences(preferences_name)
          ''')
              .eq('id', response.user!.id)
              .single();

      AppLogger.debug(
        'Raw user data from database: $userData',
        tag: 'AuthRemoteDataSource',
      );
      AppLogger.info(
        'User data retrieved successfully',
        tag: 'AuthRemoteDataSource',
      );

      // Transform the joined data to include preference_name
      final transformedUserData = Map<String, dynamic>.from(userData);
      if (transformedUserData['preferences'] != null &&
          transformedUserData['preferences']['preferences_name'] != null) {
        transformedUserData['preference_name'] =
            transformedUserData['preferences']['preferences_name'];
      }
      transformedUserData.remove('preferences'); // Remove the nested object

      return UserModel.fromJson(transformedUserData);
    } on AuthException catch (e) {
      AppLogger.error(
        'Auth exception during login',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      AppLogger.error(
        'Unexpected error during login',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat login. Silakan coba lagi.');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? username,
    String? fullname,
    String? gender,
  }) async {
    AppLogger.info('Starting user registration', tag: 'AuthRemoteDataSource');
    AppLogger.debug(
      'Registration request for email: $email',
      tag: 'AuthRemoteDataSource',
    );

    try {
      // 1. Create user with Supabase Auth
      AppLogger.debug(
        'Creating user with Supabase Auth',
        tag: 'AuthRemoteDataSource',
      );
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        AppLogger.error(
          'Auth response user is null',
          tag: 'AuthRemoteDataSource',
        );
        throw Exception('Gagal membuat akun. Silakan coba lagi.');
      }

      final String userId = authResponse.user!.id;
      AppLogger.info(
        'User created successfully with ID: $userId',
        tag: 'AuthRemoteDataSource',
      );

      // Wait a moment to ensure auth session is properly established
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Insert to users table with additional data
      final userData = <String, dynamic>{
        'id': userId,
        'email': email,
        'username': username,
        'fullname': fullname,
        'gender': gender,
        'is_profile_complete': false,
        'preference_id':
            null, // Explicitly set to null for initial registration
      };

      AppLogger.debug(
        'User data to be inserted: $userData',
        tag: 'AuthRemoteDataSource',
      );
      AppLogger.debug(
        'Inserting user data to users table',
        tag: 'AuthRemoteDataSource',
      );

      final insertResponse =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .insert(userData)
              .select()
              .single();

      AppLogger.info(
        'User data inserted successfully',
        tag: 'AuthRemoteDataSource',
      );
      AppLogger.debug(
        'Insert response: $insertResponse',
        tag: 'AuthRemoteDataSource',
      );

      return UserModel.fromJson(insertResponse);
    } on AuthException catch (e) {
      AppLogger.error(
        'Auth exception during registration',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception(_getAuthErrorMessage(e));
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database exception during registration',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception(_getPostgrestErrorMessage(e));
    } catch (e) {
      AppLogger.error(
        'Unexpected error during registration',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat registrasi. Silakan coba lagi.');
    }
  }

  @override
  Future<void> logout() async {
    AppLogger.info('Starting user logout', tag: 'AuthRemoteDataSource');
    try {
      await _supabase.auth.signOut();
      AppLogger.info(
        'User logged out successfully',
        tag: 'AuthRemoteDataSource',
      );
    } catch (e) {
      AppLogger.error(
        'Error during logout',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal keluar dari aplikasi. Silakan coba lagi.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    AppLogger.debug('Getting current user', tag: 'AuthRemoteDataSource');
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        AppLogger.debug('No current user found', tag: 'AuthRemoteDataSource');
        return null;
      }

      AppLogger.debug(
        'Current user found with ID: ${user.id}',
        tag: 'AuthRemoteDataSource',
      );

      // Get user data from users table with preference name
      final userData =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .select('''
            *,
            preferences(preferences_name)
          ''')
              .eq('id', user.id)
              .single();

      AppLogger.info(
        'Current user data retrieved successfully',
        tag: 'AuthRemoteDataSource',
      );

      // Transform the joined data to include preference_name
      final transformedUserData = Map<String, dynamic>.from(userData);
      if (transformedUserData['preferences'] != null &&
          transformedUserData['preferences']['preferences_name'] != null) {
        transformedUserData['preference_name'] =
            transformedUserData['preferences']['preferences_name'];
      }
      transformedUserData.remove('preferences'); // Remove the nested object

      return UserModel.fromJson(transformedUserData);
    } catch (e) {
      AppLogger.error(
        'Error getting current user',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    AppLogger.debug('Checking login status', tag: 'AuthRemoteDataSource');
    final isLoggedIn = _supabase.auth.currentUser != null;
    AppLogger.debug(
      'User logged in status: $isLoggedIn',
      tag: 'AuthRemoteDataSource',
    );
    return isLoggedIn;
  }

  @override
  Future<void> resetPassword(String email) async {
    AppLogger.info(
      'Starting password reset for email: $email',
      tag: 'AuthRemoteDataSource',
    );
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      AppLogger.info(
        'Password reset email sent successfully',
        tag: 'AuthRemoteDataSource',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to send password reset email',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal mengirim email reset password.');
    }
  }

  String _getAuthErrorMessage(AuthException error) {
    AppLogger.debug(
      'Processing auth error: ${error.message}',
      tag: 'AuthRemoteDataSource',
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

  String _getPostgrestErrorMessage(PostgrestException error) {
    switch (error.code) {
      case '23505': // unique_violation
        if (error.details?.toString().contains('email') == true) {
          return 'Email sudah terdaftar. Silakan gunakan email lain.';
        }
        return 'Data sudah ada. Silakan coba lagi dengan data yang berbeda.';
      case '23503': // foreign_key_violation
        return 'Data referensi tidak valid.';
      case '23514': // check_violation
        return 'Data tidak memenuhi kriteria yang diperlukan.';
      default:
        return 'Terjadi kesalahan pada server.';
    }
  }
}
