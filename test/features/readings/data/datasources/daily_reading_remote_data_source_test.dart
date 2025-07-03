import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nimbrung_mobile/features/readings/data/datasources/daily_reading_remote_data_source.dart';

@GenerateMocks([SupabaseClient])
import 'daily_reading_remote_data_source_test.mocks.dart';

void main() {
  group('DailyReadingRemoteDataSource', () {
    late DailyReadingRemoteDataSourceImpl dataSource;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      dataSource = DailyReadingRemoteDataSourceImpl(mockSupabaseClient);
    });

    group('completeReading', () {
      test(
        'should return success result when RPC completes successfully',
        () async {
          // Arrange
          const userId = 'test-user-id';
          const readingId = 'test-reading-id';
          const readTimeSeconds = 300;
          const wasHelpful = true;
          const userNote = 'Great reading!';

          final expectedResponse = {
            'success': true,
            'current_day': 2,
            'total_completed': 1,
            'streak_days': 1,
          };

          when(
            mockSupabaseClient.rpc(
              'complete_reading',
              params: anyNamed('params'),
            ),
          ).thenAnswer((_) async => expectedResponse);

          // Act
          final result = await dataSource.completeReading(
            userId: userId,
            readingId: readingId,
            readTimeSeconds: readTimeSeconds,
            wasHelpful: wasHelpful,
            userNote: userNote,
          );

          // Assert
          expect(result, expectedResponse);
          verify(
            mockSupabaseClient.rpc(
              'complete_reading',
              params: {
                'user_id': userId,
                'reading_id': readingId,
                'read_time_seconds': readTimeSeconds,
                'was_helpful': wasHelpful,
                'user_note': userNote,
              },
            ),
          ).called(1);
        },
      );

      test(
        'should throw exception with helpful message when RPC function missing',
        () async {
          // Arrange
          const userId = 'test-user-id';
          const readingId = 'test-reading-id';

          when(
            mockSupabaseClient.rpc(
              'complete_reading',
              params: anyNamed('params'),
            ),
          ).thenThrow(Exception('function complete_reading does not exist'));

          // Act & Assert
          expect(
            () => dataSource.completeReading(
              userId: userId,
              readingId: readingId,
            ),
            throwsA(
              allOf(
                isA<Exception>(),
                predicate<Exception>(
                  (e) =>
                      e.toString().contains('Database schema not initialized'),
                ),
              ),
            ),
          );
        },
      );

      test('should handle ambiguous column error gracefully', () async {
        // Arrange
        const userId = 'test-user-id';
        const readingId = 'test-reading-id';

        when(
          mockSupabaseClient.rpc(
            'complete_reading',
            params: anyNamed('params'),
          ),
        ).thenThrow(Exception('column reference "user_id" is ambiguous'));

        // Act & Assert
        expect(
          () =>
              dataSource.completeReading(userId: userId, readingId: readingId),
          throwsA(
            allOf(
              isA<Exception>(),
              predicate<Exception>(
                (e) => e.toString().contains('Database schema not initialized'),
              ),
            ),
          ),
        );
      });
    });
  });
}
