import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/reading_subject.dart';
import '../repositories/daily_reading_repository.dart';

class GetReadingSubjects {
  final DailyReadingRepository repository;

  GetReadingSubjects(this.repository);

  Future<Either<Failure, List<ReadingSubject>>> call(String userId) async {
    AppLogger.info(
      'Getting reading subjects for user: $userId',
      tag: 'GetReadingSubjects',
    );

    try {
      final result = await repository.getReadingSubjects(userId);

      return result.fold(
        (failure) {
          AppLogger.error(
            'Failed to get reading subjects: ${failure.message}',
            tag: 'GetReadingSubjects',
          );
          return Left(failure);
        },
        (subjects) {
          AppLogger.info(
            'Successfully fetched ${subjects.length} reading subjects',
            tag: 'GetReadingSubjects',
          );
          return Right(subjects);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in GetReadingSubjects',
        tag: 'GetReadingSubjects',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure());
    }
  }
}
