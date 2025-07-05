import '../repositories/daily_reading_repository.dart';
import '../../../../core/utils/logger.dart';

class MarkAsReadUseCase {
  final DailyReadingRepository _repository;

  MarkAsReadUseCase(this._repository);

  Future<bool> call(String userId, String readingId) async {
    AppLogger.info(
      'UseCase: Marking as read - user: $userId, reading: $readingId',
      tag: 'MarkAsReadUseCase',
    );

    try {
      final result = await _repository.markAsRead(userId, readingId);
      AppLogger.info(
        'UseCase: Mark as read result: $result',
        tag: 'MarkAsReadUseCase',
      );
      return result;
    } catch (e) {
      AppLogger.error(
        'UseCase: Failed to mark as read',
        tag: 'MarkAsReadUseCase',
        error: e,
      );
      rethrow;
    }
  }
}
