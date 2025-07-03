import '../../domain/entities/reading_completion.dart';

class ReadingCompletionModel extends ReadingCompletion {
  const ReadingCompletionModel({
    required super.id,
    required super.userId,
    required super.readingId,
    required super.completedAt,
    super.actualReadTimeSeconds,
    super.wasHelpful,
    super.userNote,
  });

  factory ReadingCompletionModel.fromJson(Map<String, dynamic> json) {
    return ReadingCompletionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      readingId: json['reading_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      actualReadTimeSeconds: json['actual_read_time_seconds'] as int?,
      wasHelpful: json['was_helpful'] as bool?,
      userNote: json['user_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reading_id': readingId,
      'completed_at': completedAt.toIso8601String(),
      'actual_read_time_seconds': actualReadTimeSeconds,
      'was_helpful': wasHelpful,
      'user_note': userNote,
    };
  }

  @override
  ReadingCompletionModel copyWith({
    String? id,
    String? userId,
    String? readingId,
    DateTime? completedAt,
    int? actualReadTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  }) {
    return ReadingCompletionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      readingId: readingId ?? this.readingId,
      completedAt: completedAt ?? this.completedAt,
      actualReadTimeSeconds:
          actualReadTimeSeconds ?? this.actualReadTimeSeconds,
      wasHelpful: wasHelpful ?? this.wasHelpful,
      userNote: userNote ?? this.userNote,
    );
  }
}
