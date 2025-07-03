import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/user_reading_progress.dart';
import '../repositories/daily_reading_repository.dart';

class GetUserProgress {
  final DailyReadingRepository repository;

  GetUserProgress(this.repository);

  Future<Either<Failure, UserReadingProgress?>> call(
    String userId,
    String subjectId,
  ) async {
    AppLogger.info(
      'Getting user progress for user: $userId, subject: $subjectId',
      tag: 'GetUserProgress',
    );

    try {
      final result = await repository.getUserProgress(userId, subjectId);

      return result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get user progress: ${failure.message}',
            tag: 'GetUserProgress',
          );
          return Left(failure);
        },
        (progress) {
          AppLogger.info(
            'Successfully fetched user progress: ${progress?.currentDay ?? 'null'}',
            tag: 'GetUserProgress',
          );
          return Right(progress);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetUserProgress',
        tag: 'GetUserProgress',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure());
    }
  }
}
