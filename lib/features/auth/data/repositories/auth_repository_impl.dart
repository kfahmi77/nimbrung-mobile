import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/preference.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Login failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? username,
    String? fullname,
    String? gender,
  }) async {
    try {
      final result = await remoteDataSource.register(
        email: email,
        password: password,
        username: username,
        fullname: fullname,
        gender: gender,
      );
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Registration failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      AppLogger.error(
        'Repository: Logout failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getCurrentUser();
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Get current user failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final result = await remoteDataSource.isLoggedIn();
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Check login status failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile(String userId) async {
    try {
      final result = await remoteDataSource.getUserProfile(userId);
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Get user profile failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? avatar,
  }) async {
    try {
      final result = await remoteDataSource.updateProfile(
        userId: userId,
        bio: bio,
        birthPlace: birthPlace,
        dateBirth: dateBirth,
        preferenceId: preferenceId,
        avatar: avatar,
      );
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Update profile failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Preference>>> getPreferences() async {
    try {
      final result = await remoteDataSource.getPreferences();
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Get preferences failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Preference>> createPreference(
    String preferenceName,
  ) async {
    try {
      final result = await remoteDataSource.createPreference(preferenceName);
      return Right(result);
    } catch (e) {
      AppLogger.error(
        'Repository: Create preference failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      AppLogger.error(
        'Repository: Reset password failed',
        tag: 'AuthRepository',
        error: e,
      );
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
