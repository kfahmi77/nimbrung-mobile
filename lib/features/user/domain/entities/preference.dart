import 'package:equatable/equatable.dart';

class Preference extends Equatable {
  final String id;
  final String? preferencesName;
  final DateTime createdAt;

  const Preference({
    required this.id,
    this.preferencesName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, preferencesName, createdAt];

  Preference copyWith({
    String? id,
    String? preferencesName,
    DateTime? createdAt,
  }) {
    return Preference(
      id: id ?? this.id,
      preferencesName: preferencesName ?? this.preferencesName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
