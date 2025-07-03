import '../../domain/entities/daily_reading.dart';

class DailyReadingModel extends DailyReading {
  const DailyReadingModel({
    required super.id,
    required super.subjectId,
    required super.daySequence,
    required super.title,
    required super.content,
    super.keyInsight,
    super.tomorrowHint,
    super.readTimeMinutes = 5,
    super.internalDifficulty = 1,
    super.internalLevel,
    super.prerequisitesMet = true,
    required super.createdAt,
    super.subjectName,
    super.isCompleted = false,
  });

  factory DailyReadingModel.fromJson(Map<String, dynamic> json) {
    // Extract required fields with better error handling
    final readingId = json['reading_id'] as String? ?? json['id'] as String?;
    final subjectId = json['subject_id'] as String?;
    final daySequence = json['day_sequence'] as int?;
    final title = json['title'] as String?;
    final content = json['content'] as String?;
    final createdAtStr = json['created_at'] as String?;

    // Validate required fields
    if (readingId == null || readingId.isEmpty) {
      throw FormatException('Missing required field: reading_id or id');
    }
    if (subjectId == null || subjectId.isEmpty) {
      throw FormatException('Missing required field: subject_id');
    }
    if (daySequence == null) {
      throw FormatException('Missing required field: day_sequence');
    }
    if (title == null || title.isEmpty) {
      throw FormatException('Missing required field: title');
    }
    if (content == null || content.isEmpty) {
      throw FormatException('Missing required field: content');
    }
    if (createdAtStr == null || createdAtStr.isEmpty) {
      throw FormatException('Missing required field: created_at');
    }

    return DailyReadingModel(
      id: readingId,
      subjectId: subjectId,
      daySequence: daySequence,
      title: title,
      content: content,
      keyInsight: json['key_insight'] as String?,
      tomorrowHint: json['tomorrow_hint'] as String?,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 5,
      internalDifficulty: json['internal_difficulty'] as int? ?? 1,
      internalLevel: json['internal_level'] as String?,
      prerequisitesMet: json['prerequisites_met'] as bool? ?? true,
      createdAt: DateTime.parse(createdAtStr),
      subjectName: json['subject_name'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'day_sequence': daySequence,
      'title': title,
      'content': content,
      'key_insight': keyInsight,
      'tomorrow_hint': tomorrowHint,
      'read_time_minutes': readTimeMinutes,
      'internal_difficulty': internalDifficulty,
      'internal_level': internalLevel,
      'prerequisites_met': prerequisitesMet,
      'created_at': createdAt.toIso8601String(),
      'subject_name': subjectName,
      'is_completed': isCompleted,
    };
  }

  @override
  DailyReadingModel copyWith({
    String? id,
    String? subjectId,
    int? daySequence,
    String? title,
    String? content,
    String? keyInsight,
    String? tomorrowHint,
    int? readTimeMinutes,
    int? internalDifficulty,
    String? internalLevel,
    bool? prerequisitesMet,
    DateTime? createdAt,
    String? subjectName,
    bool? isCompleted,
  }) {
    return DailyReadingModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      daySequence: daySequence ?? this.daySequence,
      title: title ?? this.title,
      content: content ?? this.content,
      keyInsight: keyInsight ?? this.keyInsight,
      tomorrowHint: tomorrowHint ?? this.tomorrowHint,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      internalDifficulty: internalDifficulty ?? this.internalDifficulty,
      internalLevel: internalLevel ?? this.internalLevel,
      prerequisitesMet: prerequisitesMet ?? this.prerequisitesMet,
      createdAt: createdAt ?? this.createdAt,
      subjectName: subjectName ?? this.subjectName,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
