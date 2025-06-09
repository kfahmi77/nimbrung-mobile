class ReadingReview {
  final int id;
  final String title;
  final String content;
  final Category category;
  final Author author;
  final String coverImageUrl;
  final String reference;

  ReadingReview({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.coverImageUrl,
    required this.reference,
  });

  factory ReadingReview.fromJson(Map<String, dynamic> json) {
    return ReadingReview(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: Category.fromJson(json['category']),
      author: Author.fromJson(json['author']),
      coverImageUrl: json['cover_image_url'],
      reference: json['reference'],
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}

class Author {
  final int id;
  final String name;

  Author({required this.id, required this.name});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(id: json['id'], name: json['name']);
  }
}

class ReadingReviewResponse {
  final bool success;
  final String message;
  final int statusCode;
  final List<ReadingReview> data;
  final dynamic error;
  final Meta meta;

  ReadingReviewResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    required this.data,
    required this.error,
    required this.meta,
  });

  factory ReadingReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReadingReviewResponse(
      success: json['success'],
      message: json['message'],
      statusCode: json['status_code'],
      data:
          (json['data'] as List)
              .map((item) => ReadingReview.fromJson(item))
              .toList(),
      error: json['error'],
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Meta {
  final String timestamp;
  final String requestId;

  Meta({required this.timestamp, required this.requestId});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(timestamp: json['timestamp'], requestId: json['request_id']);
  }
}
