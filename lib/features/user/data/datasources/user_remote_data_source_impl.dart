import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';
import '../models/preference_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient _supabase = SupabaseConfig.instance;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    AppLogger.info(
      'Getting user profile for ID: $userId',
      tag: 'UserRemoteDataSource',
    );

    try {
      final userData =
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
        tag: 'UserRemoteDataSource',
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
        'Error getting user profile',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memuat profil pengguna. Silakan coba lagi.');
    }
  }

  @override
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
  }) async {
    AppLogger.info(
      'Updating user profile for ID: $userId',
      tag: 'UserRemoteDataSource',
    );

    try {
      final updateData = <String, dynamic>{};

      if (username != null) updateData['username'] = username;
      if (fullname != null) updateData['fullname'] = fullname;
      if (bio != null) updateData['bio'] = bio;
      if (birthPlace != null) updateData['birth_place'] = birthPlace;
      if (dateBirth != null) {
        updateData['date_birth'] = dateBirth.toIso8601String().split('T')[0];
      }
      if (preferenceId != null) updateData['preference_id'] = preferenceId;
      if (avatar != null) updateData['avatar'] = avatar;
      if (gender != null) updateData['gender'] = gender;

      // First, get current user data to check profile completeness
      final currentUser = await getUserProfile(userId);

      // Create merged data from current user + updates to check completeness
      final mergedData = <String, dynamic>{
        'username': updateData['username'] ?? currentUser.username,
        'fullname': updateData['fullname'] ?? currentUser.fullname,
        'bio': updateData['bio'] ?? currentUser.bio,
        'birth_place': updateData['birth_place'] ?? currentUser.birthPlace,
        'date_birth':
            updateData['date_birth'] ??
            currentUser.dateBirth?.toIso8601String().split('T')[0],
        'preference_id':
            updateData['preference_id'] ?? currentUser.preferenceId,
        'avatar': updateData['avatar'] ?? currentUser.avatar,
        'gender': updateData['gender'] ?? currentUser.gender,
      };

      // Check if profile is complete (all required fields are filled)
      final isProfileComplete = _checkProfileCompleteness(mergedData);
      updateData['is_profile_complete'] = isProfileComplete;

      AppLogger.debug('Update data: $updateData', tag: 'UserRemoteDataSource');
      AppLogger.info(
        'Profile completeness: $isProfileComplete',
        tag: 'UserRemoteDataSource',
      );

      await _supabase
          .from(SupabaseConfig.usersTable)
          .update(updateData)
          .eq('id', userId);

      AppLogger.info(
        'User profile updated successfully',
        tag: 'UserRemoteDataSource',
      );

      // Fetch updated user data with preference name
      return await getUserProfile(userId);
    } catch (e) {
      AppLogger.error(
        'Error updating user profile',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memperbarui profil. Silakan coba lagi.');
    }
  }

  @override
  Future<UserModel> updateAvatar({
    required String userId,
    required String avatarPath,
  }) async {
    AppLogger.info(
      'Updating user avatar for ID: $userId',
      tag: 'UserRemoteDataSource',
    );

    try {
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update({
            'avatar': avatarPath,
            // Remove updated_at to avoid timezone parsing issues
          })
          .eq('id', userId);

      AppLogger.info(
        'User avatar updated successfully',
        tag: 'UserRemoteDataSource',
      );

      // Return updated user data
      return await getUserProfile(userId);
    } catch (e) {
      AppLogger.error(
        'Error updating user avatar',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memperbarui foto profil. Silakan coba lagi.');
    }
  }

  @override
  Future<List<PreferenceModel>> getPreferences() async {
    AppLogger.info('Fetching preferences', tag: 'UserRemoteDataSource');

    try {
      final response = await _supabase
          .from(SupabaseConfig.preferencesTable)
          .select('*')
          .order('preferences_name');

      AppLogger.info(
        'Preferences fetched successfully',
        tag: 'UserRemoteDataSource',
      );

      return (response as List)
          .map((preference) => PreferenceModel.fromJson(preference))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Error fetching preferences',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memuat preferensi. Silakan coba lagi.');
    }
  }

  @override
  Future<PreferenceModel> getPreferenceById(String preferenceId) async {
    AppLogger.info(
      'Getting preference by ID: $preferenceId',
      tag: 'UserRemoteDataSource',
    );

    try {
      final response =
          await _supabase
              .from(SupabaseConfig.preferencesTable)
              .select('*')
              .eq('id', preferenceId)
              .single();

      AppLogger.info(
        'Preference retrieved successfully',
        tag: 'UserRemoteDataSource',
      );

      return PreferenceModel.fromJson(response);
    } catch (e) {
      AppLogger.error(
        'Error getting preference by ID',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memuat preferensi. Silakan coba lagi.');
    }
  }

  @override
  Future<PreferenceModel> createPreference(String preferenceName) async {
    AppLogger.info(
      'Creating new preference: $preferenceName',
      tag: 'UserRemoteDataSource',
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
        tag: 'UserRemoteDataSource',
      );

      return PreferenceModel.fromJson(response);
    } catch (e) {
      AppLogger.error(
        'Error creating preference',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal membuat preferensi baru. Silakan coba lagi.');
    }
  }

  @override
  Future<List<UserModel>> searchUsers({
    String? query,
    String? preferenceId,
    int limit = 20,
    int offset = 0,
  }) async {
    AppLogger.info(
      'Searching users with query: $query',
      tag: 'UserRemoteDataSource',
    );

    try {
      var queryBuilder = _supabase.from(SupabaseConfig.usersTable).select('''
            *,
            preferences(preferences_name)
          ''');

      // Add filters
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'username.ilike.%$query%,fullname.ilike.%$query%',
        );
      }

      if (preferenceId != null) {
        queryBuilder = queryBuilder.eq('preference_id', preferenceId);
      }

      final response = await queryBuilder
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      AppLogger.info('Users search completed', tag: 'UserRemoteDataSource');

      return (response as List).map((userData) {
        // Transform the joined data to include preference_name
        final transformedUserData = Map<String, dynamic>.from(userData);
        if (transformedUserData['preferences'] != null &&
            transformedUserData['preferences']['preferences_name'] != null) {
          transformedUserData['preference_name'] =
              transformedUserData['preferences']['preferences_name'];
        }
        transformedUserData.remove('preferences'); // Remove the nested object

        return UserModel.fromJson(transformedUserData);
      }).toList();
    } catch (e) {
      AppLogger.error(
        'Error searching users',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal mencari pengguna. Silakan coba lagi.');
    }
  }

  @override
  Future<void> followUser(String targetUserId) async {
    AppLogger.info(
      'Following user: $targetUserId',
      tag: 'UserRemoteDataSource',
    );

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // This would require a follows table in the future
      // For now, just log the action
      AppLogger.info(
        'Follow functionality not implemented yet',
        tag: 'UserRemoteDataSource',
      );

      // TODO: Implement follows table and logic
      // await _supabase.from('follows').insert({
      //   'follower_id': currentUser.id,
      //   'following_id': targetUserId,
      // });
    } catch (e) {
      AppLogger.error(
        'Error following user',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal mengikuti pengguna. Silakan coba lagi.');
    }
  }

  @override
  Future<void> unfollowUser(String targetUserId) async {
    AppLogger.info(
      'Unfollowing user: $targetUserId',
      tag: 'UserRemoteDataSource',
    );

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // This would require a follows table in the future
      // For now, just log the action
      AppLogger.info(
        'Unfollow functionality not implemented yet',
        tag: 'UserRemoteDataSource',
      );

      // TODO: Implement follows table and logic
      // await _supabase.from('follows')
      //     .delete()
      //     .eq('follower_id', currentUser.id)
      //     .eq('following_id', targetUserId);
    } catch (e) {
      AppLogger.error(
        'Error unfollowing user',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal berhenti mengikuti pengguna. Silakan coba lagi.');
    }
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) async {
    AppLogger.info(
      'Getting following for user: $userId',
      tag: 'UserRemoteDataSource',
    );

    try {
      // TODO: Implement follows table and logic
      AppLogger.info(
        'Following functionality not implemented yet',
        tag: 'UserRemoteDataSource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error getting following',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memuat daftar mengikuti. Silakan coba lagi.');
    }
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    AppLogger.info(
      'Getting followers for user: $userId',
      tag: 'UserRemoteDataSource',
    );

    try {
      // TODO: Implement follows table and logic
      AppLogger.info(
        'Followers functionality not implemented yet',
        tag: 'UserRemoteDataSource',
      );
      return [];
    } catch (e) {
      AppLogger.error(
        'Error getting followers',
        tag: 'UserRemoteDataSource',
        error: e,
      );
      throw Exception('Gagal memuat daftar pengikut. Silakan coba lagi.');
    }
  }

  /// Check if all required profile fields are completed
  bool _checkProfileCompleteness(Map<String, dynamic> userData) {
    // Define required fields for profile completion
    final requiredFields = [
      'username',
      'fullname',
      'bio',
      'birth_place',
      'date_birth',
      'preference_id',
      'gender',
    ];

    // Check if all required fields have non-null and non-empty values
    for (final field in requiredFields) {
      final value = userData[field];

      // Check if field is null or empty string
      if (value == null || (value is String && value.trim().isEmpty)) {
        AppLogger.debug(
          'Profile incomplete: field "$field" is null or empty',
          tag: 'UserRemoteDataSource',
        );
        return false;
      }
    }

    AppLogger.debug(
      'Profile is complete: all required fields are filled',
      tag: 'UserRemoteDataSource',
    );
    return true;
  }
}
