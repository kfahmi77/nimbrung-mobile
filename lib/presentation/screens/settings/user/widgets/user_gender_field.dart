import 'package:flutter/material.dart';
import '../../../../themes/color_schemes.dart';

/// Widget for gender selection dropdown
class UserGenderField extends StatelessWidget {
  final String? selectedGender;
  final bool isEditing;
  final ValueChanged<String?> onChanged;

  const UserGenderField({
    super.key,
    required this.selectedGender,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          prefixIcon: Icon(Icons.wc_outlined, color: AppColors.primary),
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
          fillColor: isEditing ? Colors.white : Colors.grey[50],
        ),
        items: const [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ],
        onChanged: isEditing ? onChanged : null,
      ),
    );
  }
}
