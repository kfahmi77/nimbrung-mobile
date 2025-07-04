import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/daily_reading_remote_data_source.dart';
import '../../data/repositories/daily_reading_repository_impl.dart';
import '../../domain/entities/daily_reading.dart';
import '../../domain/entities/reading_subject.dart';
import '../../domain/entities/user_reading_progress.dart';
import '../../domain/repositories/daily_reading_repository.dart';
import '../../domain/usecases/complete_reading.dart';
import '../../domain/usecases/get_reading_subjects.dart';
import '../../domain/usecases/get_today_reading.dart';
import '../../domain/usecases/get_user_progress.dart';
import '../../domain/usecases/record_reading_feedback.dart';
import '../../domain/usecases/reading_testing_usecases.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Data source provider
final dailyReadingRemoteDataSourceProvider =
    Provider<DailyReadingRemoteDataSource>((ref) {
      final supabaseClient = ref.watch(supabaseClientProvider);
      return DailyReadingRemoteDataSourceImpl(supabaseClient);
    });

// Repository provider
final dailyReadingRepositoryProvider = Provider<DailyReadingRepository>((ref) {
  final remoteDataSource = ref.watch(dailyReadingRemoteDataSourceProvider);
  return DailyReadingRepositoryImpl(remoteDataSource);
});

// Use case providers
final getTodayReadingUseCaseProvider = Provider<GetTodayReading>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return GetTodayReading(repository);
});

final getReadingSubjectsUseCaseProvider = Provider<GetReadingSubjects>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return GetReadingSubjects(repository);
});

final completeReadingUseCaseProvider = Provider<CompleteReading>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return CompleteReading(repository);
});

final getUserProgressUseCaseProvider = Provider<GetUserProgress>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return GetUserProgress(repository);
});

final recordReadingFeedbackUseCaseProvider = Provider<RecordReadingFeedback>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return RecordReadingFeedback(repository);
});

// Testing use case providers
final simulateDayChangeUseCaseProvider = Provider<SimulateDayChange>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return SimulateDayChange(repository);
});

final resetToDay1UseCaseProvider = Provider<ResetToDay1>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return ResetToDay1(repository);
});

final getReadingInfoUseCaseProvider = Provider<GetReadingInfo>((ref) {
  final repository = ref.watch(dailyReadingRepositoryProvider);
  return GetReadingInfo(repository);
});

// State providers
final todayReadingProvider = FutureProvider.family<DailyReading?, String>((
  ref,
  userId,
) async {
  final useCase = ref.watch(getTodayReadingUseCaseProvider);
  final result = await useCase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (reading) => reading,
  );
});

// Enhanced today reading provider with auto-refresh
final autoRefreshTodayReadingProvider = FutureProvider.family<DailyReading?, String>((
  ref,
  userId,
) async {
  // Set up a timer to invalidate the base provider every hour to check for new day
  final timer = Timer.periodic(const Duration(hours: 1), (timer) {
    ref.invalidate(todayReadingProvider(userId));
  });
  
  // Clean up timer when provider is disposed
  ref.onDispose(() {
    timer.cancel();
  });
  
  // Get the regular reading - the backend should handle giving us today's reading
  return ref.watch(todayReadingProvider(userId).future);
});

final readingSubjectsProvider =
    FutureProvider.family<List<ReadingSubject>, String>((ref, userId) async {
      final useCase = ref.watch(getReadingSubjectsUseCaseProvider);
      final result = await useCase(userId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (subjects) => subjects,
      );
    });

final userProgressProvider =
    FutureProvider.family<UserReadingProgress?, (String, String)>((
      ref,
      params,
    ) async {
      final (userId, subjectId) = params;
      final useCase = ref.watch(getUserProgressUseCaseProvider);
      final result = await useCase(userId, subjectId);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (progress) => progress,
      );
    });

// Reading info provider for testing
final readingInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  final useCase = ref.watch(getReadingInfoUseCaseProvider);
  final result = await useCase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (info) => info,
  );
});

// Reading completion notifier
class ReadingCompletionNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final CompleteReading _completeReadingUseCase;
  final RecordReadingFeedback _recordFeedbackUseCase;

  ReadingCompletionNotifier(this._completeReadingUseCase, this._recordFeedbackUseCase)
    : super(const AsyncValue.data(null));

  Future<void> completeReading({
    required String userId,
    required String readingId,
    int? readTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  }) async {
    state = const AsyncValue.loading();

    final result = await _completeReadingUseCase(
      userId: userId,
      readingId: readingId,
      readTimeSeconds: readTimeSeconds,
      wasHelpful: wasHelpful,
      userNote: userNote,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (response) => AsyncValue.data(response),
    );
  }

  // Quick reaction method for thumb up/down
  Future<void> quickReaction({
    required String userId,
    required String readingId,
    required bool isHelpful,
  }) async {
    state = const AsyncValue.loading();

    final result = await _completeReadingUseCase(
      userId: userId,
      readingId: readingId,
      readTimeSeconds: 60, // Default 1 minute reading time for quick reaction
      wasHelpful: isHelpful,
      userNote: null, // No note for quick reaction
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (response) => AsyncValue.data(response),
    );
  }

  // Quick feedback method for thumb up/down (without completing)
  Future<void> recordFeedback({
    required String userId,
    required String readingId,
    required bool isHelpful,
  }) async {
    state = const AsyncValue.loading();

    final result = await _recordFeedbackUseCase(
      RecordReadingFeedbackParams(
        userId: userId,
        readingId: readingId,
        wasHelpful: isHelpful,
      ),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (response) => AsyncValue.data(response),
    );
  }
}

final readingCompletionProvider = StateNotifierProvider<
  ReadingCompletionNotifier,
  AsyncValue<Map<String, dynamic>?>
>((ref) {
  final completeUseCase = ref.watch(completeReadingUseCaseProvider);
  final feedbackUseCase = ref.watch(recordReadingFeedbackUseCaseProvider);
  return ReadingCompletionNotifier(completeUseCase, feedbackUseCase);
});

// Reading Testing Notifier
class ReadingTestingNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Ref _ref;

  ReadingTestingNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> simulateDayChange({
    required String userId,
    int daysToAdvance = 1,
  }) async {
    state = const AsyncValue.loading();

    final useCase = _ref.read(simulateDayChangeUseCaseProvider);
    final result = await useCase(
      SimulateDayChangeParams(
        userId: userId,
        daysToAdvance: daysToAdvance,
      ),
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (response) => AsyncValue.data(response),
    );

    // Refresh reading data after day change
    _ref.invalidate(autoRefreshTodayReadingProvider(userId));
  }

  Future<void> resetToDay1(String userId) async {
    state = const AsyncValue.loading();

    final useCase = _ref.read(resetToDay1UseCaseProvider);
    final result = await useCase(userId);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (response) => AsyncValue.data(response),
    );

    // Refresh reading data after reset
    _ref.invalidate(autoRefreshTodayReadingProvider(userId));
  }

  Future<void> getReadingInfo(String userId) async {
    state = const AsyncValue.loading();

    final useCase = _ref.read(getReadingInfoUseCaseProvider);
    final result = await useCase(userId);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (response) => AsyncValue.data(response),
    );
  }
}

final readingTestingProvider = StateNotifierProvider<
  ReadingTestingNotifier,
  AsyncValue<Map<String, dynamic>?>
>((ref) {
  return ReadingTestingNotifier(ref);
});
