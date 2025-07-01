import 'package:flutter/material.dart';
import 'user_info_card.dart';
import 'user_preference_field.dart';
import '../../../../../features/user/domain/entities/preference.dart';

/// Widget for the preference section
class PreferenceInfoSection extends StatelessWidget {
  final String? selectedPreferenceId;
  final bool isEditing;
  final ValueChanged<Preference?> onChanged;

  const PreferenceInfoSection({
    super.key,
    required this.selectedPreferenceId,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UserInfoCard(
      title: 'Preferensi',
      children: [
        UserPreferenceField(
          selectedPreferenceId: selectedPreferenceId,
          isEditing: isEditing,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
