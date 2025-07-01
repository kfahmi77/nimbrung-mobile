import 'package:flutter/material.dart';
import '../../../../themes/color_schemes.dart';

/// Widget for birth date selection
class UserBirthDateField extends StatelessWidget {
  final DateTime? selectedBirthDate;
  final bool isEditing;
  final VoidCallback onTap;

  const UserBirthDateField({
    super.key,
    required this.selectedBirthDate,
    required this.isEditing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: TextEditingController(
          text:
              selectedBirthDate != null
                  ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
                  : '',
        ),
        enabled: isEditing,
        readOnly: true,
        onTap: isEditing ? onTap : null,
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primary,
          ),
          suffixIcon:
              isEditing
                  ? Icon(Icons.arrow_drop_down, color: AppColors.primary)
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: isEditing ? Colors.white : Colors.grey[50],
        ),
      ),
    );
  }
}
