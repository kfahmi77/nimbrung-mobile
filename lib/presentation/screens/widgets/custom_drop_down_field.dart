import 'package:flutter/material.dart';

import '../../themes/color_schemes.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;
  final Widget? prefixIcon;
  final bool showInfo;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.prefixIcon,
    this.showInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F4F4F),
              ),
            ),
            if (showInfo) Icon(Icons.info_outline, color: Colors.grey[600]),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          value: value,
          hint:
              prefixIcon != null
                  ? Row(
                    children: [
                      prefixIcon!,
                      const SizedBox(width: 8),
                      Text(hintText),
                    ],
                  )
                  : Text(hintText),
          items:
              items.map((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
