import '../../domain/repositories/daily_reading_repository.dart';
import '../datasources/daily_reading_remote_data_source.dart';
import '../models/daily_reading_model.dart';
import '../../../../core/utils/logger.dart';

class DailyReadingRepositoryImpl implements DailyReadingRepository {
  final DailyReadingRemoteDataSource _remoteDataSource;

  DailyReadingRepositoryImpl(this._remoteDataSource);

  @override
  Future<DailyReading> getDailyReading(String userId) async {
    AppLogger.info(
      'Repository: Getting daily reading for user: $userId',
      tag: 'DailyReadingRepository',
    );

    try {
      final reading = await _remoteDataSource.getDailyReading(userId);
      AppLogger.info(
        'Repository: Successfully got daily reading: ${reading.id}',
        tag: 'DailyReadingRepository',
      );
      return reading;
    } catch (e) {
      AppLogger.error(
        'Repository: Failed to get daily reading',
        tag: 'DailyReadingRepository',
        error: e,
      );
      throw Exception('Failed to get daily reading: $e');
    }
  }

  @override
  Future<bool> submitFeedback(
    String userId,
    String readingId,
    String feedbackType,
  ) async {
    AppLogger.info(
      'Repository: Submitting feedback - user: $userId, reading: $readingId, type: $feedbackType',
      tag: 'DailyReadingRepository',
    );

    try {
      final result = await _remoteDataSource.submitFeedback(
        userId,
        readingId,
        feedbackType,
      );
      final success = result['success'] == true;
      AppLogger.info(
        'Repository: Feedback submission result: $success',
        tag: 'DailyReadingRepository',
      );
      return success;
    } catch (e) {
      AppLogger.error(
        'Repository: Failed to submit feedback',
        tag: 'DailyReadingRepository',
        error: e,
      );
      throw Exception('Failed to submit feedback: $e');
    }
  }

  @override
  Future<bool> markAsRead(String userId, String readingId) async {
    AppLogger.info(
      'Repository: Marking as read - user: $userId, reading: $readingId',
      tag: 'DailyReadingRepository',
    );

    try {
      final result = await _remoteDataSource.markAsRead(userId, readingId);
      final success = result['success'] == true;
      AppLogger.info(
        'Repository: Mark as read result: $success',
        tag: 'DailyReadingRepository',
      );
      return success;
    } catch (e) {
      AppLogger.error(
        'Repository: Failed to mark as read',
        tag: 'DailyReadingRepository',
        error: e,
      );
      throw Exception('Failed to mark reading as read: $e');
    }
  }
}
