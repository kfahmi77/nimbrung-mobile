import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/daily_reading.dart';
import '../repositories/daily_reading_repository.dart';

class GetTodayReading {
  final DailyReadingRepository repository;

  GetTodayReading(this.repository);

  Future<Either<Failure, DailyReading?>> call(
    String userId, {
    int? targetDay,
  }) async {
    AppLogger.info(
      'Getting today reading for user: $userId',
      tag: 'GetTodayReading',
    );

    try {
      final result = await repository.getTodayReading(
        userId,
        targetDay: targetDay,
      );

      return result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get today reading: ${failure.message}',
            tag: 'GetTodayReading',
          );
          return Left(failure);
        },
        (reading) {
          AppLogger.info(
            'Successfully fetched today reading: ${reading?.title ?? 'null'}',
            tag: 'GetTodayReading',
          );
          return Right(reading);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetTodayReading',
        tag: 'GetTodayReading',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure());
    }
  }
}
