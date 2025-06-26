import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String? username;
  final String? fullname;
  final String email;
  final String? avatar;
  final String? bio;
  final DateTime? dateBirth;
  final String? birthPlace;
  final bool isPremium;
  final String? preferenceId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String role;
  final String? gender;
  final String statusUser;
  final bool isProfileComplete;

  const UserModel({
    required this.id,
    this.username,
    this.fullname,
    required this.email,
    this.avatar,
    this.bio,
    this.dateBirth,
    this.birthPlace,
    this.isPremium = false,
    this.preferenceId,
    required this.createdAt,
    this.updatedAt,
    this.role = 'user',
    this.gender,
    this.statusUser = 'active',
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      dateBirth: _parseDateTime(json['date_birth']),
      birthPlace: json['birth_place'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      preferenceId: json['preference_id'] as String?,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']),
      role: json['role'] as String? ?? 'user',
      gender: json['gender'] as String?,
      statusUser: json['status_user'] as String? ?? 'active',
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }

  /// Helper method to safely parse datetime strings
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is String) {
        // Handle various datetime formats from database
        if (value.contains('T') || value.contains(' ')) {
          return DateTime.parse(value);
        } else if (value.contains(':')) {
          // Handle time-only format by adding today's date
          final now = DateTime.now();
          final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T$value';
          return DateTime.parse(dateStr);
        } else {
          // Handle date-only format
          return DateTime.parse(value);
        }
      }
      return null;
    } catch (e) {
      // Return null if parsing fails, don't crash the app
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullname': fullname,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'date_birth': dateBirth?.toIso8601String(),
      'birth_place': birthPlace,
      'is_premium': isPremium,
      'preference_id': preferenceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
      'gender': gender,
      'status_user': statusUser,
      'is_profile_complete': isProfileComplete,
    };
  }

  Map<String, dynamic> toInsertJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'fullname': fullname,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'is_premium': isPremium,
      'role': role,
      'gender': gender,
      'status_user': statusUser,
      'is_profile_complete': isProfileComplete,
    };

    if (dateBirth != null) {
      data['date_birth'] =
          dateBirth!.toIso8601String().split('T')[0]; // Format: YYYY-MM-DD
    }
    if (birthPlace != null) {
      data['birth_place'] = birthPlace;
    }
    if (preferenceId != null) {
      data['preference_id'] = preferenceId;
    }

    return data;
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? fullname,
    String? email,
    String? avatar,
    String? bio,
    DateTime? dateBirth,
    String? birthPlace,
    bool? isPremium,
    String? preferenceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    String? gender,
    String? statusUser,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      dateBirth: dateBirth ?? this.dateBirth,
      birthPlace: birthPlace ?? this.birthPlace,
      isPremium: isPremium ?? this.isPremium,
      preferenceId: preferenceId ?? this.preferenceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      statusUser: statusUser ?? this.statusUser,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullname,
    email,
    avatar,
    bio,
    dateBirth,
    birthPlace,
    isPremium,
    preferenceId,
    createdAt,
    updatedAt,
    role,
    gender,
    statusUser,
    isProfileComplete,
  ];
}
