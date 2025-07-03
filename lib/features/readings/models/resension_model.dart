import '../../../core/models/api_error.dart';
import '../../../core/models/base_response.dart';
import '../../../core/models/meta.dart';
import '../domain/entities/resension.dart';

class ReadingReviewModel extends ReadingReview {
  const ReadingReviewModel({
    required super.id,
    required super.title,
    required super.content,
    required super.category,
    required super.author,
    required super.coverImageUrl,
    required super.reference,
  });

  factory ReadingReviewModel.fromJson(Map<String, dynamic> json) {
    return ReadingReviewModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: CategoryModel.fromJson(json['category'] ?? {}),
      author: AuthorModel.fromJson(json['author'] ?? {}),
      coverImageUrl: json['cover_image_url'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': (category as CategoryModel).toJson(),
      'author': (author as AuthorModel).toJson(),
      'cover_image_url': coverImageUrl,
      'reference': reference,
    };
  }
}

class CategoryModel extends Category {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class AuthorModel extends Author {
  const AuthorModel({required super.id, required super.name});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ReadingReviewResponse extends BaseResponse<List<ReadingReviewModel>> {
  const ReadingReviewResponse({
    required super.success,
    required super.message,
    required super.statusCode,
    super.data,
    super.error,
    required super.meta,
  });

  factory ReadingReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReadingReviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['status_code'] ?? 0,
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((item) => ReadingReviewModel.fromJson(item))
                  .toList()
              : null,
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}
