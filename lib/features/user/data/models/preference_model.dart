import '../../domain/entities/preference.dart';

class PreferenceModel extends Preference {
  const PreferenceModel({
    required super.id,
    super.preferencesName,
    required super.createdAt,
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

  // Convert model to entity
  Preference toEntity() {
    return Preference(
      id: id,
      preferencesName: preferencesName,
      createdAt: createdAt,
    );
  }

  @override
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
}
