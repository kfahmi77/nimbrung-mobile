class Comment {
  final String userName;
  final String userImageUrl;
  final String timeAgo;
  final String text;
  final bool? isExpert;
  int? likesCount;
  int? repliesCount;
  bool? isLiked;
  final List<Comment>? replies;

  Comment({
    required this.userName,
    required this.userImageUrl,
    required this.timeAgo,
    required this.text,
    this.isExpert = false,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    this.replies,
  });

  Comment copyWith({
    String? userName,
    String? userImageUrl,
    String? timeAgo,
    String? text,
    bool? isExpert,
    int? likesCount,
    int? repliesCount,
    bool? isLiked,
    List<Comment>? replies,
  }) {
    return Comment(
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      text: text ?? this.text,
      isExpert: isExpert ?? this.isExpert,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}
