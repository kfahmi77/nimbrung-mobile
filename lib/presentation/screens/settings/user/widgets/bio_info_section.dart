import 'package:flutter/material.dart';
import 'user_info_card.dart';
import 'user_text_info_field.dart';

/// Widget for the bio section
class BioInfoSection extends StatelessWidget {
  final TextEditingController bioController;
  final bool isEditing;

  const BioInfoSection({
    super.key,
    required this.bioController,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return UserInfoCard(
      title: 'Bio',
      children: [
        UserTextInfoField(
          label: 'Bio',
          controller: bioController,
          icon: Icons.info_outline,
          isEditing: isEditing,
          maxLines: 4,
        ),
      ],
    );
  }
}
