import 'package:equatable/equatable.dart';

class ReadingDiscussion extends Equatable {
  final String id;
  final String readingId;
  final String createdBy;
  final String title;
  final String? description;
  final bool isPinned;
  final bool isLocked;
  final int totalComments;
  final int totalParticipants;
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReadingDiscussion({
    required this.id,
    required this.readingId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.isPinned,
    required this.isLocked,
    required this.totalComments,
    required this.totalParticipants,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    readingId,
    createdBy,
    title,
    description,
    isPinned,
    isLocked,
    totalComments,
    totalParticipants,
    lastActivityAt,
    createdAt,
    updatedAt,
  ];

  ReadingDiscussion copyWith({
    String? id,
    String? readingId,
    String? createdBy,
    String? title,
    String? description,
    bool? isPinned,
    bool? isLocked,
    int? totalComments,
    int? totalParticipants,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingDiscussion(
      id: id ?? this.id,
      readingId: readingId ?? this.readingId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      totalComments: totalComments ?? this.totalComments,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
