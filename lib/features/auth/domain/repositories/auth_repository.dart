import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../user/domain/entities/user.dart';

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

  /// Password reset
  Future<Either<Failure, void>> resetPassword(String email);
}
