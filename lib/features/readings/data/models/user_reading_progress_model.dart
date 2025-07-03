import '../../domain/entities/user_reading_progress.dart';

class UserReadingProgressModel extends UserReadingProgress {
  const UserReadingProgressModel({
    required super.id,
    required super.userId,
    required super.subjectId,
    super.currentDay = 1,
    super.totalCompleted = 0,
    super.streakDays = 0,
    required super.startedDate,
    super.lastReadDate,
    super.milestone30 = false,
    super.milestone100 = false,
    super.milestone365 = false,
  });

  factory UserReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return UserReadingProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subjectId: json['subject_id'] as String,
      currentDay: json['current_day'] as int? ?? 1,
      totalCompleted: json['total_completed'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      startedDate: DateTime.parse(json['started_date'] as String),
      lastReadDate:
          json['last_read_date'] != null
              ? DateTime.parse(json['last_read_date'] as String)
              : null,
      milestone30: json['milestone_30'] as bool? ?? false,
      milestone100: json['milestone_100'] as bool? ?? false,
      milestone365: json['milestone_365'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'current_day': currentDay,
      'total_completed': totalCompleted,
      'streak_days': streakDays,
      'started_date': startedDate.toIso8601String().split('T')[0],
      'last_read_date': lastReadDate?.toIso8601String().split('T')[0],
      'milestone_30': milestone30,
      'milestone_100': milestone100,
      'milestone_365': milestone365,
    };
  }

  @override
  UserReadingProgressModel copyWith({
    String? id,
    String? userId,
    String? subjectId,
    int? currentDay,
    int? totalCompleted,
    int? streakDays,
    DateTime? startedDate,
    DateTime? lastReadDate,
    bool? milestone30,
    bool? milestone100,
    bool? milestone365,
  }) {
    return UserReadingProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      currentDay: currentDay ?? this.currentDay,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      streakDays: streakDays ?? this.streakDays,
      startedDate: startedDate ?? this.startedDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      milestone30: milestone30 ?? this.milestone30,
      milestone100: milestone100 ?? this.milestone100,
      milestone365: milestone365 ?? this.milestone365,
    );
  }
}
