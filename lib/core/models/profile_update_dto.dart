class ProfileUpdateRequest {
  final String? bio;
  final String? birthPlace;
  final DateTime? dateBirth;
  final String? preferenceId; // Changed from selectedField to preferenceId
  final String? avatar;

  const ProfileUpdateRequest({
    this.bio,
    this.birthPlace,
    this.dateBirth,
    this.preferenceId, // Changed from selectedField to preferenceId
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'is_profile_complete': true, // Always set to true when updating profile
    };

    if (bio != null) {
      data['bio'] = bio;
    }
    if (birthPlace != null) {
      data['birth_place'] = birthPlace;
    }
    if (dateBirth != null) {
      data['date_birth'] =
          dateBirth!.toIso8601String().split('T')[0]; // Format: YYYY-MM-DD
    }
    if (preferenceId != null) {
      data['preference_id'] = preferenceId; // Map to correct database column
    }
    if (avatar != null) {
      data['avatar'] = avatar;
    }

    return data;
  }
}

class ProfileUpdateResponse {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? userData;

  const ProfileUpdateResponse({
    required this.isSuccess,
    required this.message,
    this.userData,
  });

  factory ProfileUpdateResponse.success({
    required String message,
    Map<String, dynamic>? userData,
  }) {
    return ProfileUpdateResponse(
      isSuccess: true,
      message: message,
      userData: userData,
    );
  }

  factory ProfileUpdateResponse.failure({required String message}) {
    return ProfileUpdateResponse(isSuccess: false, message: message);
  }
}
