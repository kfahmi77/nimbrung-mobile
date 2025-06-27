import '../models/user_model.dart';
import '../models/preference_model.dart';

abstract class AuthRemoteDataSource {
  /// Authentication methods
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String email,
    required String password,
    String? username,
    String? fullname,
    String? gender,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<bool> isLoggedIn();

  /// Profile methods
  Future<UserModel> getUserProfile(String userId);

  Future<UserModel> updateProfile({
    required String userId,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? avatar,
  });

  /// Preference methods
  Future<List<PreferenceModel>> getPreferences();

  Future<PreferenceModel> createPreference(String preferenceName);

  /// Password reset
  Future<void> resetPassword(String email);
}
