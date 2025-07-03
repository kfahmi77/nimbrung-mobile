import 'package:equatable/equatable.dart';

class ReadingCompletion extends Equatable {
  final String id;
  final String userId;
  final String readingId;
  final DateTime completedAt;
  final int? actualReadTimeSeconds;
  final bool? wasHelpful;
  final String? userNote;

  const ReadingCompletion({
    required this.id,
    required this.userId,
    required this.readingId,
    required this.completedAt,
    this.actualReadTimeSeconds,
    this.wasHelpful,
    this.userNote,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    readingId,
    completedAt,
    actualReadTimeSeconds,
    wasHelpful,
    userNote,
  ];

  ReadingCompletion copyWith({
    String? id,
    String? userId,
    String? readingId,
    DateTime? completedAt,
    int? actualReadTimeSeconds,
    bool? wasHelpful,
    String? userNote,
  }) {
    return ReadingCompletion(
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
