import 'package:equatable/equatable.dart';

class User extends Equatable {
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
  final String? preferenceName; // Added preference name from joined table
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String role;
  final String? gender;
  final String statusUser;
  final bool isProfileComplete;

  const User({
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
    this.preferenceName, // Added preference name
    required this.createdAt,
    this.updatedAt,
    this.role = 'user',
    this.gender,
    this.statusUser = 'active',
    this.isProfileComplete = false,
  });

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
    preferenceName, // Added preference name
    createdAt,
    updatedAt,
    role,
    gender,
    statusUser,
    isProfileComplete,
  ];

  User copyWith({
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
    String? preferenceName, // Added preference name
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    String? gender,
    String? statusUser,
    bool? isProfileComplete,
  }) {
    return User(
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
      preferenceName:
          preferenceName ?? this.preferenceName, // Added preference name
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      statusUser: statusUser ?? this.statusUser,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
