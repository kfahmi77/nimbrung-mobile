import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/preference_model.dart';
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

      final response =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .insert(userData)
              .select('''
            *,
            preferences(preferences_name)
          ''')
              .single();

      AppLogger.info(
        'User registration completed successfully',
        tag: 'AuthRemoteDataSource',
      );

      // Transform the joined data to include preference_name
      final transformedResponse = Map<String, dynamic>.from(response);
      if (transformedResponse['preferences'] != null &&
          transformedResponse['preferences']['preferences_name'] != null) {
        transformedResponse['preference_name'] =
            transformedResponse['preferences']['preferences_name'];
      }
      transformedResponse.remove('preferences'); // Remove the nested object

      return UserModel.fromJson(transformedResponse);
    } on AuthException catch (e) {
      AppLogger.error(
        'Auth exception during registration',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception(_getAuthErrorMessage(e));
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error during registration',
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
      throw Exception(
        'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.',
      );
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
        'Failed to logout user',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal logout. Silakan coba lagi.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      AppLogger.debug(
        'Current user found: ${user.email}',
        tag: 'AuthRemoteDataSource',
      );
      return await getUserProfile(user.id);
    } else {
      AppLogger.debug('No current user found', tag: 'AuthRemoteDataSource');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final isLoggedIn = _supabase.auth.currentUser != null;
    AppLogger.debug(
      'User logged in status: $isLoggedIn',
      tag: 'AuthRemoteDataSource',
    );
    return isLoggedIn;
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    AppLogger.debug(
      'Getting user profile for ID: $userId',
      tag: 'AuthRemoteDataSource',
    );
    try {
      final response =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .select('''
            *,
            preferences(preferences_name)
          ''')
              .eq('id', userId)
              .single();

      AppLogger.info(
        'User profile retrieved successfully',
        tag: 'AuthRemoteDataSource',
      );

      // Transform the joined data to include preference_name
      final userData = Map<String, dynamic>.from(response);
      if (userData['preferences'] != null &&
          userData['preferences']['preferences_name'] != null) {
        userData['preference_name'] =
            userData['preferences']['preferences_name'];
      }
      userData.remove('preferences'); // Remove the nested object

      return UserModel.fromJson(userData);
    } catch (e) {
      AppLogger.error(
        'Failed to get user profile',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal mengambil profil pengguna.');
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? avatar,
  }) async {
    AppLogger.info(
      'Starting profile update for user: $userId',
      tag: 'AuthRemoteDataSource',
    );

    try {
      final updateData = <String, dynamic>{'is_profile_complete': true};

      if (bio != null) updateData['bio'] = bio;
      if (birthPlace != null) updateData['birth_place'] = birthPlace;
      if (dateBirth != null) {
        updateData['date_birth'] = dateBirth.toIso8601String().split('T')[0];
      }
      if (preferenceId != null) updateData['preference_id'] = preferenceId;
      if (avatar != null) updateData['avatar'] = avatar;

      AppLogger.debug(
        'Updating user profile in database',
        tag: 'AuthRemoteDataSource',
      );
      final response =
          await _supabase
              .from(SupabaseConfig.usersTable)
              .update(updateData)
              .eq('id', userId)
              .select('''
            *,
            preferences(preferences_name)
          ''')
              .single();

      AppLogger.info(
        'Profile updated successfully for user: $userId',
        tag: 'AuthRemoteDataSource',
      );

      // Transform the joined data to include preference_name
      final transformedResponse = Map<String, dynamic>.from(response);
      if (transformedResponse['preferences'] != null &&
          transformedResponse['preferences']['preferences_name'] != null) {
        transformedResponse['preference_name'] =
            transformedResponse['preferences']['preferences_name'];
      }
      transformedResponse.remove('preferences'); // Remove the nested object

      return UserModel.fromJson(transformedResponse);
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error during profile update',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception(_getPostgrestErrorMessage(e));
    } catch (e) {
      AppLogger.error(
        'Unexpected error during profile update',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception(
        'Terjadi kesalahan saat memperbarui profil. Silakan coba lagi.',
      );
    }
  }

  @override
  Future<List<PreferenceModel>> getPreferences() async {
    AppLogger.debug('Getting all preferences', tag: 'AuthRemoteDataSource');
    try {
      final response =
          await _supabase.from(SupabaseConfig.preferencesTable).select();

      AppLogger.info(
        'Preferences retrieved successfully',
        tag: 'AuthRemoteDataSource',
      );
      return (response as List)
          .map((item) => PreferenceModel.fromJson(item))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to get preferences',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal mengambil data preferensi.');
    }
  }

  @override
  Future<PreferenceModel> createPreference(String preferenceName) async {
    AppLogger.info(
      'Creating new preference: $preferenceName',
      tag: 'AuthRemoteDataSource',
    );
    try {
      final response =
          await _supabase
              .from(SupabaseConfig.preferencesTable)
              .insert({'preferences_name': preferenceName})
              .select()
              .single();

      AppLogger.info(
        'Preference created successfully',
        tag: 'AuthRemoteDataSource',
      );
      return PreferenceModel.fromJson(response);
    } catch (e) {
      AppLogger.error(
        'Failed to create preference',
        tag: 'AuthRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal membuat preferensi baru.');
    }
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
