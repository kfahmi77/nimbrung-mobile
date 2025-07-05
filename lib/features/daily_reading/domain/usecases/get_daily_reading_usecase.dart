import '../repositories/daily_reading_repository.dart';
import '../../data/models/daily_reading_model.dart';
import '../../../../core/utils/logger.dart';

class GetDailyReadingUseCase {
  final DailyReadingRepository _repository;

  GetDailyReadingUseCase(this._repository);

  Future<DailyReading> call(String userId) async {
    AppLogger.info(
      'UseCase: Getting daily reading for user: $userId',
      tag: 'GetDailyReadingUseCase',
    );

    try {
      final reading = await _repository.getDailyReading(userId);
      AppLogger.info(
        'UseCase: Successfully retrieved daily reading: ${reading.id}, scope: ${reading.scopeName}',
        tag: 'GetDailyReadingUseCase',
      );
      return reading;
    } catch (e) {
      AppLogger.error(
        'UseCase: Failed to get daily reading',
        tag: 'GetDailyReadingUseCase',
        error: e,
      );
      rethrow;
    }
  }
}
