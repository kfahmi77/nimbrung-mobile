import 'package:equatable/equatable.dart';

class PreferenceModel extends Equatable {
  final String id;
  final String? preferencesName;
  final DateTime createdAt;

  const PreferenceModel({
    required this.id,
    this.preferencesName,
    required this.createdAt,
  });

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      id: json['id'] as String,
      preferencesName: json['preferences_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preferences_name': preferencesName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {'preferences_name': preferencesName};
  }

  PreferenceModel copyWith({
    String? id,
    String? preferencesName,
    DateTime? createdAt,
  }) {
    return PreferenceModel(
      id: id ?? this.id,
      preferencesName: preferencesName ?? this.preferencesName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, preferencesName, createdAt];
}
