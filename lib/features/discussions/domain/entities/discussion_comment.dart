import 'package:equatable/equatable.dart';

class DiscussionComment extends Equatable {
  final String id;
  final String discussionId;
  final String? parentCommentId;
  final String userId;
  final String content;
  final bool isExpertComment;
  final int likesCount;
  final int repliesCount;
  final bool isPinned;
  final bool isDeleted;
  final bool isLikedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DiscussionComment>? replies;

  const DiscussionComment({
    required this.id,
    required this.discussionId,
    this.parentCommentId,
    required this.userId,
    required this.content,
    required this.isExpertComment,
    required this.likesCount,
    required this.repliesCount,
    required this.isPinned,
    required this.isDeleted,
    required this.isLikedByUser,
    required this.createdAt,
    required this.updatedAt,
    this.replies,
  });

  @override
  List<Object?> get props => [
    id,
    discussionId,
    parentCommentId,
    userId,
    content,
    isExpertComment,
    likesCount,
    repliesCount,
    isPinned,
    isDeleted,
    isLikedByUser,
    createdAt,
    updatedAt,
    replies,
  ];

  DiscussionComment copyWith({
    String? id,
    String? discussionId,
    String? parentCommentId,
    String? userId,
    String? content,
    bool? isExpertComment,
    int? likesCount,
    int? repliesCount,
    bool? isPinned,
    bool? isDeleted,
    bool? isLikedByUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DiscussionComment>? replies,
  }) {
    return DiscussionComment(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isExpertComment: isExpertComment ?? this.isExpertComment,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
    );
  }

  /// Helper method to check if this is a reply to another comment
  bool get isReply => parentCommentId != null;

  /// Helper method to check if this comment has replies
  bool get hasReplies => repliesCount > 0;

  /// Helper method to get reply level (for nested UI)
  int get replyLevel {
    if (!isReply) return 0;
    // Could be calculated based on parent comment's level + 1
    return 1; // For now, we support max 1 level of nesting
  }
}
