import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/preference.dart';

abstract class AuthRepository {
  /// Authentication methods
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? username,
    String? fullname,
    String? gender,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();

  /// Profile methods
  Future<Either<Failure, User>> getUserProfile(String userId);

  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? bio,
    String? birthPlace,
    DateTime? dateBirth,
    String? preferenceId,
    String? avatar,
  });

  /// Preference methods
  Future<Either<Failure, List<Preference>>> getPreferences();

  Future<Either<Failure, Preference>> createPreference(String preferenceName);

  /// Password reset
  Future<Either<Failure, void>> resetPassword(String email);
}
