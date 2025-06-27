import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/preference.dart';
import '../repositories/auth_repository.dart';

class GetPreferencesUseCase implements UseCase<List<Preference>, NoParams> {
  final AuthRepository repository;

  GetPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Preference>>> call(NoParams params) async {
    return await repository.getPreferences();
  }
}
