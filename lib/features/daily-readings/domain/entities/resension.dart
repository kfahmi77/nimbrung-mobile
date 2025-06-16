import 'package:equatable/equatable.dart';

class ReadingReview extends Equatable {
  final int id;
  final String title;
  final String content;
  final Category category;
  final Author author;
  final String coverImageUrl;
  final String reference;

  const ReadingReview({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.coverImageUrl,
    required this.reference,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    category,
    author,
    coverImageUrl,
    reference,
  ];
}

class Category extends Equatable {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Author extends Equatable {
  final int id;
  final String name;

  const Author({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
