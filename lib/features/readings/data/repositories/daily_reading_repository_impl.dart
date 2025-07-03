import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/daily_reading.dart';
import '../../domain/entities/reading_subject.dart';
import '../../domain/entities/user_reading_progress.dart';
import '../../domain/repositories/daily_reading_repository.dart';
import '../datasources/daily_reading_remote_data_source.dart';

class DailyReadingRepositoryImpl implements DailyReadingRepository {
  final DailyReadingRemoteDataSource remoteDataSource;

  DailyReadingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DailyReading?>> getTodayReading(
    String userId, {
    int? targetDay,
  }) async {
    try {
      final result = await remoteDataSource.getTodayReading(
        userId,
        targetDay: targetDay,
      );
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Failed to get today reading',
        tag: 'DailyReadingRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        ServerFailure(
          message: 'Failed to get today reading: $e',
          code: 'GET_TODAY_READING_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ReadingSubject>>> getReadingSubjects(
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getReadingSubjects(userId);
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Failed to get reading subjects',
        tag: 'DailyReadingRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        ServerFailure(
          message: 'Failed to get reading subjects: $e',
          code: 'GET_READING_SUBJECTS_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserReadingProgress?>> getUserProgress(
    String userId,
    String subjectId,
  ) async {
    try {
      final result = await remoteDataSource.getUserProgress(userId, subjectId);
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Failed to get user progress',
        tag: 'DailyReadingRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        ServerFailure(
          message: 'Failed to get user progress: $e',
          code: 'GET_USER_PROGRESS_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeReading({
    required String userId,
    required String readingId,
    int? readTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  }) async {
    try {
      final result = await remoteDataSource.completeReading(
        userId: userId,
        readingId: readingId,
        readTimeSeconds: readTimeSeconds,
        wasHelpful: wasHelpful,
        userNote: userNote,
      );
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Failed to complete reading',
        tag: 'DailyReadingRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        ServerFailure(
          message: 'Failed to complete reading: $e',
          code: 'COMPLETE_READING_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DailyReading>>> getReadingHistory(
    String userId,
    String subjectId,
  ) async {
    try {
      final result = await remoteDataSource.getReadingHistory(
        userId,
        subjectId,
      );
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Failed to get reading history',
        tag: 'DailyReadingRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        ServerFailure(
          message: 'Failed to get reading history: $e',
          code: 'GET_READING_HISTORY_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, DailyReading?>> getSpecificReading(
    String userId,
    String subjectId,
    int daySequence,
  ) async {
    try {
      final result = await remoteDataSource.getSpecificReading(
        userId,
        subjectId,
        daySequence,
      );
      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Repository: Failed to get specific reading',
        tag: 'DailyReadingRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        ServerFailure(
          message: 'Failed to get specific reading: $e',
          code: 'GET_SPECIFIC_READING_ERROR',
        ),
      );
    }
  }
}
