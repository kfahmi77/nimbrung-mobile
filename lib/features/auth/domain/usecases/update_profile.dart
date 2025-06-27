import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      userId: params.userId,
      bio: params.bio,
      birthPlace: params.birthPlace,
      dateBirth: params.dateBirth,
      preferenceId: params.preferenceId,
      avatar: params.avatar,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String? bio;
  final String? birthPlace;
  final DateTime? dateBirth;
  final String? preferenceId;
  final String? avatar;

  const UpdateProfileParams({
    required this.userId,
    this.bio,
    this.birthPlace,
    this.dateBirth,
    this.preferenceId,
    this.avatar,
  });

  @override
  List<Object?> get props => [
    userId,
    bio,
    birthPlace,
    dateBirth,
    preferenceId,
    avatar,
  ];
}
