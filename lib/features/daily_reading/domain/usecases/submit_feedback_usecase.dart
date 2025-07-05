import '../repositories/daily_reading_repository.dart';
import '../../../../core/utils/logger.dart';

class SubmitFeedbackUseCase {
  final DailyReadingRepository _repository;

  SubmitFeedbackUseCase(this._repository);

  Future<bool> call(String userId, String readingId, String feedbackType) async {
    AppLogger.info(
      'UseCase: Submitting feedback - user: $userId, reading: $readingId, type: $feedbackType',
      tag: 'SubmitFeedbackUseCase',
    );

    if (feedbackType != 'up' && feedbackType != 'down') {
      AppLogger.error(
        'UseCase: Invalid feedback type: $feedbackType',
        tag: 'SubmitFeedbackUseCase',
      );
      throw ArgumentError('Feedback type must be "up" or "down"');
    }

    try {
      final result = await _repository.submitFeedback(userId, readingId, feedbackType);
      AppLogger.info(
        'UseCase: Feedback submission result: $result',
        tag: 'SubmitFeedbackUseCase',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'UseCase: Failed to submit feedback',
        tag: 'SubmitFeedbackUseCase',
        error: e,
      );
      rethrow;
    }
  }
}
