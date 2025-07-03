import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/daily_reading.dart';
import '../entities/reading_subject.dart';
import '../entities/user_reading_progress.dart';

abstract class DailyReadingRepository {
  Future<Either<Failure, DailyReading?>> getTodayReading(
    String userId, {
    int? targetDay,
  });
  Future<Either<Failure, List<ReadingSubject>>> getReadingSubjects(
    String userId,
  );
  Future<Either<Failure, UserReadingProgress?>> getUserProgress(
    String userId,
    String subjectId,
  );
  Future<Either<Failure, Map<String, dynamic>>> completeReading({
    required String userId,
    required String readingId,
    int? readTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  });
  Future<Either<Failure, List<DailyReading>>> getReadingHistory(
    String userId,
    String subjectId,
  );
  Future<Either<Failure, DailyReading?>> getSpecificReading(
    String userId,
    String subjectId,
    int daySequence,
  );
}
