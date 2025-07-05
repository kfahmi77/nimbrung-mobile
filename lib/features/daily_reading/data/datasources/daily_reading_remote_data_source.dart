import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_reading_model.dart';
import '../../../../core/utils/logger.dart';

abstract class DailyReadingRemoteDataSource {
  Future<DailyReading> getDailyReading(String userId);
  Future<Map<String, dynamic>> submitFeedback(String userId, String readingId, String feedbackType);
  Future<Map<String, dynamic>> markAsRead(String userId, String readingId);
}

class DailyReadingRemoteDataSourceImpl implements DailyReadingRemoteDataSource {
  final SupabaseClient _supabase;

  DailyReadingRemoteDataSourceImpl(this._supabase);

  @override
  Future<DailyReading> getDailyReading(String userId) async {
    AppLogger.info(
      'Starting getDailyReading for user: $userId',
      tag: 'DailyReadingRemoteDataSource',
    );

    try {
      AppLogger.debug(
        'Calling get_daily_reading RPC function',
        tag: 'DailyReadingRemoteDataSource',
      );

      final response = await _supabase.rpc('get_daily_reading', params: {
        'p_user_id': userId,
      });

      AppLogger.debug(
        'RPC response type: ${response.runtimeType}',
        tag: 'DailyReadingRemoteDataSource',
      );
      AppLogger.debug(
        'RPC response received: $response',
        tag: 'DailyReadingRemoteDataSource',
      );

      if (response == null || (response is List && response.isEmpty)) {
        AppLogger.warning(
          'No daily reading found for user: $userId',
          tag: 'DailyReadingRemoteDataSource',
        );
        throw Exception('No daily reading found');
      }

      // The RPC function returns a single row
      final data = response is List ? response.first : response;
      AppLogger.debug(
        'Processing reading data: $data',
        tag: 'DailyReadingRemoteDataSource',
      );

      final reading = DailyReading.fromJson(data as Map<String, dynamic>);
      AppLogger.info(
        'Successfully parsed daily reading: ${reading.id}',
        tag: 'DailyReadingRemoteDataSource',
      );

      return reading;
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error in getDailyReading',
        tag: 'DailyReadingRemoteDataSource',
        error: e,
      );
      
      // Handle specific "structure of query does not match function result type" error
      if (e.message.contains('structure of query does not match function result type')) {
        throw Exception(
          'Database function error: The SQL function return type doesn\'t match the database schema. '
          'Please apply the updated SQL from sql/fix_function_structure_error.sql to fix this issue. '
          'Original error: ${e.message}'
        );
      }
      
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      AppLogger.error(
        'Unexpected error in getDailyReading',
        tag: 'DailyReadingRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to get daily reading: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitFeedback(
    String userId, 
    String readingId, 
    String feedbackType
  ) async {
    AppLogger.info(
      'Submitting feedback for user: $userId, reading: $readingId, type: $feedbackType',
      tag: 'DailyReadingRemoteDataSource',
    );

    try {
      AppLogger.debug(
        'Calling submit_reading_feedback RPC function',
        tag: 'DailyReadingRemoteDataSource',
      );

      final response = await _supabase.rpc('submit_reading_feedback', params: {
        'p_user_id': userId,
        'p_reading_id': readingId,
        'p_feedback_type': feedbackType,
      });

      AppLogger.debug(
        'Feedback submission response: $response',
        tag: 'DailyReadingRemoteDataSource',
      );

      final result = response as Map<String, dynamic>;
      AppLogger.info(
        'Feedback submitted successfully: ${result['success']}',
        tag: 'DailyReadingRemoteDataSource',
      );

      return result;
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error in submitFeedback',
        tag: 'DailyReadingRemoteDataSource',
        error: e,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      AppLogger.error(
        'Unexpected error in submitFeedback',
        tag: 'DailyReadingRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to submit feedback: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> markAsRead(String userId, String readingId) async {
    AppLogger.info(
      'Marking reading as read for user: $userId, reading: $readingId',
      tag: 'DailyReadingRemoteDataSource',
    );

    try {
      AppLogger.debug(
        'Calling mark_reading_as_read RPC function',
        tag: 'DailyReadingRemoteDataSource',
      );

      final response = await _supabase.rpc('mark_reading_as_read', params: {
        'p_user_id': userId,
        'p_reading_id': readingId,
      });

      AppLogger.debug(
        'Mark as read response: $response',
        tag: 'DailyReadingRemoteDataSource',
      );

      final result = response as Map<String, dynamic>;
      AppLogger.info(
        'Reading marked as read successfully: ${result['success']}',
        tag: 'DailyReadingRemoteDataSource',
      );

      return result;
    } on PostgrestException catch (e) {
      AppLogger.error(
        'Database error in markAsRead',
        tag: 'DailyReadingRemoteDataSource',
        error: e,
      );
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      AppLogger.error(
        'Unexpected error in markAsRead',
        tag: 'DailyReadingRemoteDataSource',
        error: e,
      );
      throw Exception('Failed to mark reading as read: $e');
    }
  }
}
