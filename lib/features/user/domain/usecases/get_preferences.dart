import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/preference.dart';
import '../repositories/user_repository.dart';

class GetPreferencesUseCase implements UseCase<List<Preference>, NoParams> {
  final UserRepository repository;

  GetPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Preference>>> call(NoParams params) async {
    return await repository.getPreferences();
  }
}
