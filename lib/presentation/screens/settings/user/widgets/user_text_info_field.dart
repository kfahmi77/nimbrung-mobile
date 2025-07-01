import 'package:flutter/material.dart';
import '../../../../themes/color_schemes.dart';

/// Reusable text input field for user information
class UserTextInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool isEditing;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;

  const UserTextInfoField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.isEditing,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: isEditing && enabled,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          prefixIcon:
              maxLines > 1
                  ? Padding(
                    padding: EdgeInsets.only(bottom: (maxLines - 1) * 15.0),
                    child: Icon(icon, color: AppColors.primary),
                  )
                  : Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: true,
          fillColor: isEditing && enabled ? Colors.white : Colors.grey[50],
        ),
      ),
    );
  }
}
