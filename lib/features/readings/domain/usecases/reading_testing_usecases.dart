import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/daily_reading_repository.dart';

class SimulateDayChange implements UseCase<Map<String, dynamic>, SimulateDayChangeParams> {
  final DailyReadingRepository repository;

  SimulateDayChange(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(SimulateDayChangeParams params) async {
    return await repository.simulateDayChange(
      userId: params.userId,
      daysToAdvance: params.daysToAdvance,
    );
  }
}

class SimulateDayChangeParams {
  final String userId;
  final int daysToAdvance;

  SimulateDayChangeParams({
    required this.userId,
    this.daysToAdvance = 1,
  });
}

class ResetToDay1 implements UseCase<Map<String, dynamic>, String> {
  final DailyReadingRepository repository;

  ResetToDay1(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.resetToDay1(userId);
  }
}

class GetReadingInfo implements UseCase<Map<String, dynamic>, String> {
  final DailyReadingRepository repository;

  GetReadingInfo(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getReadingInfo(userId);
  }
}
