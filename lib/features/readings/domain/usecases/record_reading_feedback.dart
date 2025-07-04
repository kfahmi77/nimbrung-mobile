import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/daily_reading_repository.dart';

class RecordReadingFeedback implements UseCase<Map<String, dynamic>, RecordReadingFeedbackParams> {
  final DailyReadingRepository repository;

  RecordReadingFeedback(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(RecordReadingFeedbackParams params) async {
    return await repository.recordReadingFeedback(
      userId: params.userId,
      readingId: params.readingId,
      wasHelpful: params.wasHelpful,
      userNote: params.userNote,
    );
  }
}

class RecordReadingFeedbackParams {
  final String userId;
  final String readingId;
  final bool wasHelpful;
  final String? userNote;

  RecordReadingFeedbackParams({
    required this.userId,
    required this.readingId,
    required this.wasHelpful,
    this.userNote,
  });
}
