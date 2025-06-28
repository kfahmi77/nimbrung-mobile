import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      userId: params.userId,
      username: params.username,
      fullname: params.fullname,
      bio: params.bio,
      birthPlace: params.birthPlace,
      dateBirth: params.dateBirth,
      preferenceId: params.preferenceId,
      avatar: params.avatar,
      gender: params.gender,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String? username;
  final String? fullname;
  final String? bio;
  final String? birthPlace;
  final DateTime? dateBirth;
  final String? preferenceId;
  final String? avatar;
  final String? gender;

  const UpdateProfileParams({
    required this.userId,
    this.username,
    this.fullname,
    this.bio,
    this.birthPlace,
    this.dateBirth,
    this.preferenceId,
    this.avatar,
    this.gender,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    fullname,
    bio,
    birthPlace,
    dateBirth,
    preferenceId,
    avatar,
    gender,
  ];
}
