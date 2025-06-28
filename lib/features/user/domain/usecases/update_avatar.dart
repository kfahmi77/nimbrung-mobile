import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateAvatarUseCase implements UseCase<User, UpdateAvatarParams> {
  final UserRepository repository;

  UpdateAvatarUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateAvatarParams params) async {
    return await repository.updateAvatar(
      userId: params.userId,
      avatarPath: params.avatarPath,
    );
  }
}

class UpdateAvatarParams extends Equatable {
  final String userId;
  final String avatarPath;

  const UpdateAvatarParams({required this.userId, required this.avatarPath});

  @override
  List<Object> get props => [userId, avatarPath];
}
