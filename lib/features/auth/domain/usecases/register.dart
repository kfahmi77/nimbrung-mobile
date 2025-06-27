import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      username: params.username,
      fullname: params.fullname,
      gender: params.gender,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String? username;
  final String? fullname;
  final String? gender;

  const RegisterParams({
    required this.email,
    required this.password,
    this.username,
    this.fullname,
    this.gender,
  });

  @override
  List<Object?> get props => [email, password, username, fullname, gender];
}
