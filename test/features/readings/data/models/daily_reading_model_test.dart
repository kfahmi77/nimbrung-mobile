import 'package:flutter_test/flutter_test.dart';
import 'package:nimbrung_mobile/features/readings/data/models/daily_reading_model.dart';

void main() {
  group('DailyReadingModel', () {
    test('should parse valid JSON correctly', () {
      // Arrange
      final json = {
        'reading_id': 'test-reading-id',
        'subject_id': 'test-subject-id',
        'subject_name': 'Flutter',
        'day_sequence': 1,
        'title': 'Test Reading',
        'content': 'This is test content',
        'key_insight': 'Key insight here',
        'tomorrow_hint': 'Tomorrow we will learn...',
        'read_time_minutes': 5,
        'created_at': '2025-01-01T10:00:00Z',
        'is_completed': false,
      };

      // Act
      final model = DailyReadingModel.fromJson(json);

      // Assert
      expect(model.id, 'test-reading-id');
      expect(model.subjectId, 'test-subject-id');
      expect(model.subjectName, 'Flutter');
      expect(model.daySequence, 1);
      expect(model.title, 'Test Reading');
      expect(model.content, 'This is test content');
      expect(model.keyInsight, 'Key insight here');
      expect(model.tomorrowHint, 'Tomorrow we will learn...');
      expect(model.readTimeMinutes, 5);
      expect(model.isCompleted, false);
    });

    test('should handle missing optional fields', () {
      // Arrange
      final json = {
        'reading_id': 'test-reading-id',
        'subject_id': 'test-subject-id',
        'day_sequence': 1,
        'title': 'Test Reading',
        'content': 'This is test content',
        'created_at': '2025-01-01T10:00:00Z',
        // Missing optional fields
      };

      // Act
      final model = DailyReadingModel.fromJson(json);

      // Assert
      expect(model.id, 'test-reading-id');
      expect(model.keyInsight, null);
      expect(model.tomorrowHint, null);
      expect(model.subjectName, null);
      expect(model.readTimeMinutes, 5); // default value
      expect(model.isCompleted, false); // default value
    });

    test('should throw FormatException for missing required fields', () {
      // Arrange
      final json = {
        'subject_id': 'test-subject-id',
        'day_sequence': 1,
        // Missing required fields: reading_id, title, content, created_at
      };

      // Act & Assert
      expect(
        () => DailyReadingModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException for null required fields', () {
      // Arrange
      final json = {
        'reading_id': null,
        'subject_id': 'test-subject-id',
        'day_sequence': 1,
        'title': 'Test Reading',
        'content': 'This is test content',
        'created_at': '2025-01-01T10:00:00Z',
      };

      // Act & Assert
      expect(
        () => DailyReadingModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should fallback to id field if reading_id is not present', () {
      // Arrange
      final json = {
        'id': 'fallback-id', // Using 'id' instead of 'reading_id'
        'subject_id': 'test-subject-id',
        'day_sequence': 1,
        'title': 'Test Reading',
        'content': 'This is test content',
        'created_at': '2025-01-01T10:00:00Z',
      };

      // Act
      final model = DailyReadingModel.fromJson(json);

      // Assert
      expect(model.id, 'fallback-id');
    });
  });
}
