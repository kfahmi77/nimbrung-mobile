import 'package:equatable/equatable.dart';

class UserReadingProgress extends Equatable {
  final String id;
  final String userId;
  final String subjectId;
  final int currentDay;
  final int totalCompleted;
  final int streakDays;
  final DateTime startedDate;
  final DateTime? lastReadDate;
  final bool milestone30;
  final bool milestone100;
  final bool milestone365;

  const UserReadingProgress({
    required this.id,
    required this.userId,
    required this.subjectId,
    this.currentDay = 1,
    this.totalCompleted = 0,
    this.streakDays = 0,
    required this.startedDate,
    this.lastReadDate,
    this.milestone30 = false,
    this.milestone100 = false,
    this.milestone365 = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    subjectId,
    currentDay,
    totalCompleted,
    streakDays,
    startedDate,
    lastReadDate,
    milestone30,
    milestone100,
    milestone365,
  ];

  UserReadingProgress copyWith({
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
    return UserReadingProgress(
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

  double get progressPercentage {
    return totalCompleted / 365.0;
  }

  bool get hasReadToday {
    if (lastReadDate == null) return false;
    final today = DateTime.now();
    final lastRead = lastReadDate!;
    return lastRead.year == today.year &&
        lastRead.month == today.month &&
        lastRead.day == today.day;
  }
}
