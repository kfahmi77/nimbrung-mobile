import '../models/user_model.dart';
import '../models/preference_model.dart';

abstract class UserRemoteDataSource {
  /// User profile methods
  Future<UserModel> getUserProfile(String userId);

  Future<UserModel> updateProfile({
    required String userId,
    String? username,
    String? fullname,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? avatar,
    String? gender,
  });

  Future<UserModel> updateAvatar({
    required String userId,
    required String avatarPath,
  });

  /// Preference methods
  Future<List<PreferenceModel>> getPreferences();

  Future<PreferenceModel> getPreferenceById(String preferenceId);

  Future<PreferenceModel> createPreference(String preferenceName);

  /// User search and discovery
  Future<List<UserModel>> searchUsers({
    String? query,
    String? preferenceId,
    int limit = 20,
    int offset = 0,
  });

  /// User follow/unfollow (for future social features)
  Future<void> followUser(String targetUserId);

  Future<void> unfollowUser(String targetUserId);

  Future<List<UserModel>> getFollowing(String userId);

  Future<List<UserModel>> getFollowers(String userId);
}
