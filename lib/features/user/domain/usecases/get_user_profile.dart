import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase implements UseCase<User, String> {
  final UserRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(String userId) async {
    return await repository.getUserProfile(userId);
  }
}
