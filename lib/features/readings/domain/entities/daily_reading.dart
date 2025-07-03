import 'package:equatable/equatable.dart';

class DailyReading extends Equatable {
  final String id;
  final String subjectId;
  final int daySequence;
  final String title;
  final String content;
  final String? keyInsight;
  final String? tomorrowHint;
  final int readTimeMinutes;
  final int internalDifficulty;
  final String? internalLevel;
  final bool prerequisitesMet;
  final DateTime createdAt;
  final String? subjectName;
  final bool isCompleted;

  const DailyReading({
    required this.id,
    required this.subjectId,
    required this.daySequence,
    required this.title,
    required this.content,
    this.keyInsight,
    this.tomorrowHint,
    this.readTimeMinutes = 5,
    this.internalDifficulty = 1,
    this.internalLevel,
    this.prerequisitesMet = true,
    required this.createdAt,
    this.subjectName,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    subjectId,
    daySequence,
    title,
    content,
    keyInsight,
    tomorrowHint,
    readTimeMinutes,
    internalDifficulty,
    internalLevel,
    prerequisitesMet,
    createdAt,
    subjectName,
    isCompleted,
  ];

  DailyReading copyWith({
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
    return DailyReading(
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
