import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/daily_reading_model.dart';
import '../../data/datasources/daily_reading_remote_data_source.dart';
import '../../data/repositories/daily_reading_repository_impl.dart';
import '../../domain/usecases/get_daily_reading_usecase.dart';
import '../../domain/usecases/submit_feedback_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../../../core/utils/logger.dart';

// Data source provider
final dailyReadingRemoteDataSourceProvider =
    Provider<DailyReadingRemoteDataSource>((ref) {
      return DailyReadingRemoteDataSourceImpl(Supabase.instance.client);
    });

// Repository provider
final dailyReadingRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.read(dailyReadingRemoteDataSourceProvider);
  return DailyReadingRepositoryImpl(remoteDataSource);
});

// Use case providers
final getDailyReadingUseCaseProvider = Provider((ref) {
  final repository = ref.read(dailyReadingRepositoryProvider);
  return GetDailyReadingUseCase(repository);
});

final submitFeedbackUseCaseProvider = Provider((ref) {
  final repository = ref.read(dailyReadingRepositoryProvider);
  return SubmitFeedbackUseCase(repository);
});

final markAsReadUseCaseProvider = Provider((ref) {
  final repository = ref.read(dailyReadingRepositoryProvider);
  return MarkAsReadUseCase(repository);
});

// State provider for daily reading
final dailyReadingProvider =
    StateNotifierProvider<DailyReadingNotifier, AsyncValue<DailyReading?>>((
      ref,
    ) {
      final getDailyReadingUseCase = ref.read(getDailyReadingUseCaseProvider);
      final submitFeedbackUseCase = ref.read(submitFeedbackUseCaseProvider);
      final markAsReadUseCase = ref.read(markAsReadUseCaseProvider);

      return DailyReadingNotifier(
        getDailyReadingUseCase,
        submitFeedbackUseCase,
        markAsReadUseCase,
      );
    });

class DailyReadingNotifier extends StateNotifier<AsyncValue<DailyReading?>> {
  final GetDailyReadingUseCase _getDailyReadingUseCase;
  final SubmitFeedbackUseCase _submitFeedbackUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;

  DailyReadingNotifier(
    this._getDailyReadingUseCase,
    this._submitFeedbackUseCase,
    this._markAsReadUseCase,
  ) : super(const AsyncValue.loading());

  Future<void> getDailyReading(String userId) async {
    AppLogger.info(
      'Provider: Getting daily reading for user: $userId',
      tag: 'DailyReadingProvider',
    );

    state = const AsyncValue.loading();

    try {
      final reading = await _getDailyReadingUseCase.call(userId);
      AppLogger.info(
        'Provider: Successfully loaded daily reading: ${reading.id}',
        tag: 'DailyReadingProvider',
      );
      state = AsyncValue.data(reading);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Provider: Failed to get daily reading',
        tag: 'DailyReadingProvider',
        error: e,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> submitFeedback(
    String userId,
    String readingId,
    String feedbackType,
  ) async {
    final currentReading = state.value;
    if (currentReading == null) {
      AppLogger.warning(
        'Provider: Cannot submit feedback - no current reading',
        tag: 'DailyReadingProvider',
      );
      return;
    }

    AppLogger.info(
      'Provider: Submitting feedback - user: $userId, reading: $readingId, type: $feedbackType',
      tag: 'DailyReadingProvider',
    );

    try {
      await _submitFeedbackUseCase.call(userId, readingId, feedbackType);

      // Update the local state with the new feedback
      final updatedReading = currentReading.copyWith(
        userFeedback: feedbackType,
      );
      AppLogger.info(
        'Provider: Feedback submitted successfully, updating local state',
        tag: 'DailyReadingProvider',
      );
      state = AsyncValue.data(updatedReading);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Provider: Failed to submit feedback',
        tag: 'DailyReadingProvider',
        error: e,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsRead(String userId, String readingId) async {
    final currentReading = state.value;
    if (currentReading == null) {
      AppLogger.warning(
        'Provider: Cannot mark as read - no current reading',
        tag: 'DailyReadingProvider',
      );
      return;
    }

    AppLogger.info(
      'Provider: Marking as read - user: $userId, reading: $readingId',
      tag: 'DailyReadingProvider',
    );

    try {
      await _markAsReadUseCase.call(userId, readingId);

      // Update the local state to mark as read
      final updatedReading = currentReading.copyWith(isRead: true);
      AppLogger.info(
        'Provider: Reading marked as read successfully, updating local state',
        tag: 'DailyReadingProvider',
      );
      state = AsyncValue.data(updatedReading);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Provider: Failed to mark as read',
        tag: 'DailyReadingProvider',
        error: e,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearReading() {
    AppLogger.info(
      'Provider: Clearing daily reading state',
      tag: 'DailyReadingProvider',
    );
    state = const AsyncValue.data(null);
  }
}
