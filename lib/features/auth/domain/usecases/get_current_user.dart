import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../user/domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
