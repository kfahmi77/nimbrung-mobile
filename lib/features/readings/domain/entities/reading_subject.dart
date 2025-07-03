import 'package:equatable/equatable.dart';

class ReadingSubject extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final String? colorHex;
  final int totalDays;
  final bool isActive;
  final DateTime createdAt;
  final String? preferenceId;

  const ReadingSubject({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.colorHex,
    this.totalDays = 365,
    this.isActive = true,
    required this.createdAt,
    this.preferenceId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconName,
    colorHex,
    totalDays,
    isActive,
    createdAt,
    preferenceId,
  ];

  ReadingSubject copyWith({
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
    return ReadingSubject(
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
