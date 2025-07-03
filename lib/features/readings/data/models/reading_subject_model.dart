import '../../domain/entities/reading_subject.dart';

class ReadingSubjectModel extends ReadingSubject {
  const ReadingSubjectModel({
    required super.id,
    required super.name,
    super.description,
    super.iconName,
    super.colorHex,
    super.totalDays = 365,
    super.isActive = true,
    required super.createdAt,
    super.preferenceId,
  });

  factory ReadingSubjectModel.fromJson(Map<String, dynamic> json) {
    return ReadingSubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      colorHex: json['color_hex'] as String?,
      totalDays: json['total_days'] as int? ?? 365,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      preferenceId: json['preference_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'color_hex': colorHex,
      'total_days': totalDays,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'preference_id': preferenceId,
    };
  }

  @override
  ReadingSubjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
    int? totalDays,
    bool? isActive,
    DateTime? createdAt,
    String? preferenceId,
  }) {
    return ReadingSubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      totalDays: totalDays ?? this.totalDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      preferenceId: preferenceId ?? this.preferenceId,
    );
  }
}
