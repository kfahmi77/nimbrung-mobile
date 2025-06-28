import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/preference.dart';

abstract class UserRepository {
  /// User profile methods
  Future<Either<Failure, User>> getUserProfile(String userId);

  Future<Either<Failure, User>> updateProfile({
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

  Future<Either<Failure, User>> updateAvatar({
    required String userId,
    required String avatarPath,
  });

  /// Preference methods
  Future<Either<Failure, List<Preference>>> getPreferences();

  Future<Either<Failure, Preference>> getPreferenceById(String preferenceId);

  Future<Either<Failure, Preference>> createPreference(String preferenceName);

  /// User search and discovery
  Future<Either<Failure, List<User>>> searchUsers({
    String? query,
    String? preferenceId,
    int limit = 20,
    int offset = 0,
  });

  /// User follow/unfollow (for future social features)
  Future<Either<Failure, void>> followUser(String targetUserId);

  Future<Either<Failure, void>> unfollowUser(String targetUserId);

  Future<Either<Failure, List<User>>> getFollowing(String userId);

  Future<Either<Failure, List<User>>> getFollowers(String userId);
}
