import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/daily_reading_repository.dart';

class CompleteReading {
  final DailyReadingRepository repository;

  CompleteReading(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String userId,
    required String readingId,
    int? readTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  }) async {
    AppLogger.info(
      'Completing reading for user: $userId, reading: $readingId',
      tag: 'CompleteReading',
    );

    try {
      final result = await repository.completeReading(
        userId: userId,
        readingId: readingId,
        readTimeSeconds: readTimeSeconds,
        wasHelpful: wasHelpful,
        userNote: userNote,
      );

      return result.fold(
        (failure) {
          AppLogger.error(
            'Failed to complete reading: ${failure.message}',
            tag: 'CompleteReading',
          );
          return Left(failure);
        },
        (response) {
          AppLogger.info(
            'Successfully completed reading',
            tag: 'CompleteReading',
          );
          return Right(response);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CompleteReading',
        tag: 'CompleteReading',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure());
    }
  }
}
