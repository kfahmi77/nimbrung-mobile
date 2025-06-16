import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../themes/color_schemes.dart';

class CustomGoogleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomGoogleButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
      ),
      icon: SvgPicture.asset('assets/images/google_logo.svg'),
    );
  }
}
