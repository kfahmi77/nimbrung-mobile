import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class SearchUsersUseCase implements UseCase<List<User>, SearchUsersParams> {
  final UserRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) async {
    return await repository.searchUsers(
      query: params.query,
      preferenceId: params.preferenceId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchUsersParams extends Equatable {
  final String? query;
  final String? preferenceId;
  final int limit;
  final int offset;

  const SearchUsersParams({
    this.query,
    this.preferenceId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, preferenceId, limit, offset];
}
