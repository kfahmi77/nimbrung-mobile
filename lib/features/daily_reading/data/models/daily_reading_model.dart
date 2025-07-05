// Daily Reading Model
class DailyReading {
  final String id;
  final String title;
  final String content;
  final String? quote;
  final String scopeName;
  final DateTime readingDate;
  final bool isRead;
  final String? userFeedback;

  const DailyReading({
    required this.id,
    required this.title,
    required this.content,
    this.quote,
    required this.scopeName,
    required this.readingDate,
    required this.isRead,
    this.userFeedback,
  });

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      quote: json['quote']?.toString(),
      scopeName: json['scope_name']?.toString() ?? 'General',
      readingDate: json['reading_date'] != null 
          ? DateTime.parse(json['reading_date'].toString())
          : DateTime.now(),
      isRead: json['is_read'] == true,
      userFeedback: json['user_feedback']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'quote': quote,
      'scope_name': scopeName,
      'reading_date': readingDate.toIso8601String().split('T')[0],
      'is_read': isRead,
      'user_feedback': userFeedback,
    };
  }

  DailyReading copyWith({
    String? id,
    String? title,
    String? content,
    String? quote,
    String? scopeName,
    DateTime? readingDate,
    bool? isRead,
    String? userFeedback,
  }) {
    return DailyReading(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      quote: quote ?? this.quote,
      scopeName: scopeName ?? this.scopeName,
      readingDate: readingDate ?? this.readingDate,
      isRead: isRead ?? this.isRead,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
