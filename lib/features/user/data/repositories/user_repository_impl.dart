import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/preference.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../services/user_image_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserImageService imageService;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.imageService,
  });

  @override
  Future<Either<Failure, User>> getUserProfile(String userId) async {
    try {
      final userModel = await remoteDataSource.getUserProfile(userId);
      return Right(userModel.toEntity());
    } catch (e) {
      AppLogger.error('Error in getUserProfile repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'GET_USER_PROFILE_ERROR'),
      );
    }
  }

  @override
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
  }) async {
    try {
      final userModel = await remoteDataSource.updateProfile(
        userId: userId,
        username: username,
        fullname: fullname,
        bio: bio,
        birthPlace: birthPlace,
        dateBirth: dateBirth,
        preferenceId: preferenceId,
        avatar: avatar,
        gender: gender,
      );
      return Right(userModel.toEntity());
    } catch (e) {
      AppLogger.error('Error in updateProfile repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'UPDATE_PROFILE_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> updateAvatar({
    required String userId,
    required String avatarPath,
  }) async {
    try {
      // 1. Upload the avatar image
      final avatarUrl = await imageService.uploadAvatar(
        userId: userId,
        imagePath: avatarPath,
      );

      // 2. Update user profile with new avatar URL
      final userModel = await remoteDataSource.updateAvatar(
        userId: userId,
        avatarPath: avatarUrl,
      );

      return Right(userModel.toEntity());
    } catch (e) {
      AppLogger.error('Error in updateAvatar repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'UPDATE_AVATAR_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Preference>>> getPreferences() async {
    try {
      final preferenceModels = await remoteDataSource.getPreferences();
      final preferences =
          preferenceModels.map((model) => model.toEntity()).toList();
      return Right(preferences);
    } catch (e) {
      AppLogger.error('Error in getPreferences repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'GET_PREFERENCES_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, Preference>> getPreferenceById(
    String preferenceId,
  ) async {
    try {
      final preferenceModel = await remoteDataSource.getPreferenceById(
        preferenceId,
      );
      return Right(preferenceModel.toEntity());
    } catch (e) {
      AppLogger.error('Error in getPreferenceById repository', error: e);
      return Left(
        ServerFailure(
          message: e.toString(),
          code: 'GET_PREFERENCE_BY_ID_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Preference>> createPreference(
    String preferenceName,
  ) async {
    try {
      final preferenceModel = await remoteDataSource.createPreference(
        preferenceName,
      );
      return Right(preferenceModel.toEntity());
    } catch (e) {
      AppLogger.error('Error in createPreference repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'CREATE_PREFERENCE_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, List<User>>> searchUsers({
    String? query,
    String? preferenceId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userModels = await remoteDataSource.searchUsers(
        query: query,
        preferenceId: preferenceId,
        limit: limit,
        offset: offset,
      );
      final users = userModels.map((model) => model.toEntity()).toList();
      return Right(users);
    } catch (e) {
      AppLogger.error('Error in searchUsers repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'SEARCH_USERS_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> followUser(String targetUserId) async {
    try {
      await remoteDataSource.followUser(targetUserId);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error in followUser repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'FOLLOW_USER_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser(String targetUserId) async {
    try {
      await remoteDataSource.unfollowUser(targetUserId);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error in unfollowUser repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'UNFOLLOW_USER_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowing(String userId) async {
    try {
      final userModels = await remoteDataSource.getFollowing(userId);
      final users = userModels.map((model) => model.toEntity()).toList();
      return Right(users);
    } catch (e) {
      AppLogger.error('Error in getFollowing repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'GET_FOLLOWING_ERROR'),
      );
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowers(String userId) async {
    try {
      final userModels = await remoteDataSource.getFollowers(userId);
      final users = userModels.map((model) => model.toEntity()).toList();
      return Right(users);
    } catch (e) {
      AppLogger.error('Error in getFollowers repository', error: e);
      return Left(
        ServerFailure(message: e.toString(), code: 'GET_FOLLOWERS_ERROR'),
      );
    }
  }
}
