import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/logger.dart';
import '../models/daily_reading_model.dart';
import '../models/reading_subject_model.dart';
import '../models/user_reading_progress_model.dart';

abstract class DailyReadingRemoteDataSource {
  Future<DailyReadingModel?> getTodayReading(String userId, {int? targetDay});
  Future<List<ReadingSubjectModel>> getReadingSubjects(String userId);
  Future<UserReadingProgressModel?> getUserProgress(
    String userId,
    String subjectId,
  );
  Future<Map<String, dynamic>> completeReading({
    required String userId,
    required String readingId,
    int? readTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  });
  Future<List<DailyReadingModel>> getReadingHistory(
    String userId,
    String subjectId,
  );
  Future<DailyReadingModel?> getSpecificReading(
    String userId,
    String subjectId,
    int daySequence,
  );
}

class DailyReadingRemoteDataSourceImpl implements DailyReadingRemoteDataSource {
  final SupabaseClient supabaseClient;

  DailyReadingRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<DailyReadingModel?> getTodayReading(
    String userId, {
    int? targetDay,
  }) async {
    try {
      AppLogger.info(
        'Getting today reading for user: $userId, targetDay: $targetDay',
        tag: 'DailyReadingDataSource',
      );

      final response = await supabaseClient.rpc(
        'get_today_reading',
        params: {
          'user_id': userId,
          if (targetDay != null) 'target_day': targetDay,
        },
      );

      if (response == null || (response is List && response.isEmpty)) {
        AppLogger.warning(
          'No reading found for user: $userId',
          tag: 'DailyReadingDataSource',
        );
        return null;
      }

      final data = response is List ? response.first : response;
      AppLogger.info(
        'Successfully fetched today reading',
        tag: 'DailyReadingDataSource',
      );
      return DailyReadingModel.fromJson(data as Map<String, dynamic>);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get today reading',
        tag: 'DailyReadingDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      // More specific error handling
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('function get_today_reading') &&
          (errorString.contains('does not exist') ||
              errorString.contains('undefined'))) {
        throw Exception(
          'RPC function get_today_reading does not exist. Please apply sql/rpc_functions_only.sql to your Supabase database.',
        );
      }

      if (errorString.contains('relation') &&
          errorString.contains('does not exist')) {
        throw Exception(
          'Database tables missing. Please ensure all required tables exist in your Supabase database.',
        );
      }

      if (errorString.contains('column') &&
          errorString.contains('does not exist')) {
        throw Exception(
          'Database schema mismatch. Some columns are missing from your tables.',
        );
      }

      if (errorString.contains('permission denied')) {
        throw Exception(
          'Permission denied accessing database. Check your RLS policies and user permissions.',
        );
      }

      // For debugging - include the original error
      throw Exception('Failed to get today reading: ${e.toString()}');
    }
  }

  @override
  Future<List<ReadingSubjectModel>> getReadingSubjects(String userId) async {
    try {
      AppLogger.info(
        'Getting reading subjects for user: $userId',
        tag: 'DailyReadingDataSource',
      );

      // First get user's preference
      final userResponse =
          await supabaseClient
              .from('users')
              .select('preference_id')
              .eq('id', userId)
              .single();

      final preferenceId = userResponse['preference_id'] as String?;

      if (preferenceId == null) {
        AppLogger.warning(
          'User has no preference set',
          tag: 'DailyReadingDataSource',
        );
        return [];
      }

      // Get subjects based on user preference
      final response = await supabaseClient
          .from('reading_subjects')
          .select('*')
          .eq('preference_id', preferenceId)
          .eq('is_active', true)
          .order('created_at');

      AppLogger.info(
        'Successfully fetched ${response.length} reading subjects',
        tag: 'DailyReadingDataSource',
      );
      return (response as List<dynamic>)
          .map(
            (json) =>
                ReadingSubjectModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get reading subjects',
        tag: 'DailyReadingDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      // If the error is related to missing tables, provide a helpful message
      if (e.toString().contains('reading_subjects') &&
          (e.toString().contains('does not exist') ||
              e.toString().contains('relation') ||
              e.toString().contains('table'))) {
        throw Exception(
          'Tables missing. Please apply sql/daily_reading_schema.sql to your Supabase database or see DAILY_READING_DATABASE_SETUP.md for instructions.',
        );
      }

      rethrow;
    }
  }

  @override
  Future<UserReadingProgressModel?> getUserProgress(
    String userId,
    String subjectId,
  ) async {
    try {
      AppLogger.info(
        'Getting user progress for user: $userId, subject: $subjectId',
        tag: 'DailyReadingDataSource',
      );

      final response =
          await supabaseClient
              .from('user_reading_progress')
              .select('*')
              .eq('user_id', userId)
              .eq('subject_id', subjectId)
              .maybeSingle();

      if (response == null) {
        AppLogger.info(
          'No progress found for user',
          tag: 'DailyReadingDataSource',
        );
        return null;
      }

      AppLogger.info(
        'Successfully fetched user progress',
        tag: 'DailyReadingDataSource',
      );
      return UserReadingProgressModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get user progress',
        tag: 'DailyReadingDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> completeReading({
    required String userId,
    required String readingId,
    int? readTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  }) async {
    try {
      AppLogger.info(
        'Completing reading for user: $userId, reading: $readingId',
        tag: 'DailyReadingDataSource',
      );

      final response = await supabaseClient.rpc(
        'complete_reading',
        params: {
          'p_user_id': userId,
          'p_reading_id': readingId,
          if (readTimeSeconds != null) 'p_read_time_seconds': readTimeSeconds,
          if (wasHelpful != null) 'p_was_helpful': wasHelpful,
          if (userNote != null) 'p_user_note': userNote,
        },
      );

      AppLogger.info(
        'Successfully completed reading',
        tag: 'DailyReadingDataSource',
      );
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to complete reading',
        tag: 'DailyReadingDataSource',
        error: e,
        stackTrace: stackTrace,
      );

      // If the error is related to missing RPC function, provide a helpful message
      if (e.toString().contains('function complete_reading') ||
          e.toString().contains('does not exist') ||
          e.toString().contains('undefined function')) {
        throw Exception(
          'RPC functions missing. Please apply sql/rpc_functions_only.sql to your Supabase database or see QUICK_FIX_RPC_FUNCTIONS.md for instructions.',
        );
      }

      rethrow;
    }
  }

  @override
  Future<List<DailyReadingModel>> getReadingHistory(
    String userId,
    String subjectId,
  ) async {
    try {
      AppLogger.info(
        'Getting reading history for user: $userId, subject: $subjectId',
        tag: 'DailyReadingDataSource',
      );

      final userPreferenceId = await _getUserPreferenceId(userId);
      if (userPreferenceId == null) {
        throw Exception('User preference not found');
      }

      final response = await supabaseClient
          .from('daily_readings')
          .select('''
            *,
            reading_subjects!inner(id, name),
            reading_completions!left(id, completed_at)
          ''')
          .eq('subject_id', subjectId)
          .eq('reading_subjects.preference_id', userPreferenceId)
          .order('day_sequence');

      AppLogger.info(
        'Successfully fetched reading history',
        tag: 'DailyReadingDataSource',
      );
      return (response as List<dynamic>).map((json) {
        final data = json as Map<String, dynamic>;
        data['is_completed'] = data['reading_completions']?.isNotEmpty == true;
        data['subject_name'] = data['reading_subjects']['name'];
        return DailyReadingModel.fromJson(data);
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get reading history',
        tag: 'DailyReadingDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<DailyReadingModel?> getSpecificReading(
    String userId,
    String subjectId,
    int daySequence,
  ) async {
    try {
      AppLogger.info(
        'Getting specific reading for user: $userId, subject: $subjectId, day: $daySequence',
        tag: 'DailyReadingDataSource',
      );

      final userPreferenceId = await _getUserPreferenceId(userId);
      if (userPreferenceId == null) {
        throw Exception('User preference not found');
      }

      final response =
          await supabaseClient
              .from('daily_readings')
              .select('''
            *,
            reading_subjects!inner(id, name),
            reading_completions!left(id, completed_at)
          ''')
              .eq('subject_id', subjectId)
              .eq('day_sequence', daySequence)
              .eq('reading_subjects.preference_id', userPreferenceId)
              .maybeSingle();

      if (response == null) {
        AppLogger.warning(
          'No specific reading found',
          tag: 'DailyReadingDataSource',
        );
        return null;
      }

      final data = response;
      data['is_completed'] = data['reading_completions']?.isNotEmpty == true;
      data['subject_name'] = data['reading_subjects']['name'];

      AppLogger.info(
        'Successfully fetched specific reading',
        tag: 'DailyReadingDataSource',
      );
      return DailyReadingModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get specific reading',
        tag: 'DailyReadingDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<String?> _getUserPreferenceId(String userId) async {
    final userResponse =
        await supabaseClient
            .from('users')
            .select('preference_id')
            .eq('id', userId)
            .single();
    return userResponse['preference_id'] as String?;
  }
}
