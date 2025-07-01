import 'package:flutter/material.dart';
import 'user_info_card.dart';
import 'user_text_info_field.dart';
import 'user_gender_field.dart';
import 'user_birth_date_field.dart';

/// Widget for the personal information section
class PersonalInfoSection extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController fullnameController;
  final TextEditingController emailController;
  final TextEditingController birthPlaceController;
  final String? selectedGender;
  final DateTime? selectedBirthDate;
  final bool isEditing;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onBirthDateTap;

  const PersonalInfoSection({
    super.key,
    required this.usernameController,
    required this.fullnameController,
    required this.emailController,
    required this.birthPlaceController,
    required this.selectedGender,
    required this.selectedBirthDate,
    required this.isEditing,
    required this.onGenderChanged,
    required this.onBirthDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return UserInfoCard(
      title: 'Informasi Pribadi',
      children: [
        UserTextInfoField(
          label: 'Username',
          controller: usernameController,
          icon: Icons.person_outline,
          isEditing: isEditing,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Username tidak boleh kosong';
            }
            return null;
          },
        ),
        UserTextInfoField(
          label: 'Nama Lengkap',
          controller: fullnameController,
          icon: Icons.badge_outlined,
          isEditing: isEditing,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Nama lengkap tidak boleh kosong';
            }
            return null;
          },
        ),
        UserTextInfoField(
          label: 'Email',
          controller: emailController,
          icon: Icons.email_outlined,
          isEditing: isEditing,
          enabled: false, // Email usually shouldn't be editable
        ),
        UserGenderField(
          selectedGender: selectedGender,
          isEditing: isEditing,
          onChanged: onGenderChanged,
        ),
        UserBirthDateField(
          selectedBirthDate: selectedBirthDate,
          isEditing: isEditing,
          onTap: onBirthDateTap,
        ),
        UserTextInfoField(
          label: 'Tempat Lahir',
          controller: birthPlaceController,
          icon: Icons.location_on_outlined,
          isEditing: isEditing,
        ),
      ],
    );
  }
}
