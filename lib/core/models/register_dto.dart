import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String email;
  final String password;
  final String? username;
  final String? fullname;
  final String? bio;
  final DateTime? dateBirth;
  final String? birthPlace;
  final String? gender;
  final String? preferenceId;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.username,
    this.fullname,
    this.bio,
    this.dateBirth,
    this.birthPlace,
    this.gender,
    this.preferenceId,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      bio: json['bio'] as String?,
      dateBirth:
          json['date_birth'] != null
              ? DateTime.parse(json['date_birth'] as String)
              : null,
      birthPlace: json['birth_place'] as String?,
      gender: json['gender'] as String?,
      preferenceId: json['preference_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'is_profile_complete':
          false, // Set default to false for new registrations
    };

    if (username != null) data['username'] = username;
    if (fullname != null) data['fullname'] = fullname;
    if (bio != null) data['bio'] = bio;
    if (dateBirth != null) {
      data['date_birth'] = dateBirth!.toIso8601String().split('T')[0];
    }
    if (birthPlace != null) data['birth_place'] = birthPlace;
    if (gender != null) data['gender'] = gender;

    // Explicitly exclude preference_id during initial registration
    // This will be set later during profile completion
    data.remove('preference_id');

    return data;
  }

  RegisterRequest copyWith({
    String? email,
    String? password,
    String? username,
    String? fullname,
    String? bio,
    DateTime? dateBirth,
    String? birthPlace,
    String? gender,
    String? preferenceId,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      bio: bio ?? this.bio,
      dateBirth: dateBirth ?? this.dateBirth,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: gender ?? this.gender,
      preferenceId: preferenceId ?? this.preferenceId,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    username,
    fullname,
    bio,
    dateBirth,
    birthPlace,
    gender,
    preferenceId,
  ];
}

class RegisterResponse extends Equatable {
  final bool success;
  final String? message;
  final String? userId;
  final Map<String, dynamic>? userData;

  const RegisterResponse({
    required this.success,
    this.message,
    this.userId,
    this.userData,
  });

  factory RegisterResponse.success({
    String? message,
    String? userId,
    Map<String, dynamic>? userData,
  }) {
    return RegisterResponse(
      success: true,
      message: message ?? 'Registration successful',
      userId: userId,
      userData: userData,
    );
  }

  factory RegisterResponse.failure({required String message}) {
    return RegisterResponse(success: false, message: message);
  }

  @override
  List<Object?> get props => [success, message, userId, userData];
}
