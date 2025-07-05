import '../../data/models/daily_reading_model.dart';

abstract class DailyReadingRepository {
  Future<DailyReading> getDailyReading(String userId);
  Future<bool> submitFeedback(
    String userId,
    String readingId,
    String feedbackType,
  );
  Future<bool> markAsRead(String userId, String readingId);
}
