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

// Reading completion notifier
class ReadingCompletionNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final CompleteReading _completeReadingUseCase;

  ReadingCompletionNotifier(this._completeReadingUseCase)
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
}

final readingCompletionProvider = StateNotifierProvider<
  ReadingCompletionNotifier,
  AsyncValue<Map<String, dynamic>?>
>((ref) {
  final useCase = ref.watch(completeReadingUseCaseProvider);
  return ReadingCompletionNotifier(useCase);
});
