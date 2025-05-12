import 'package:flutter/material.dart';
import 'app_fonts.dart';
import 'color_schemes.dart';

final TextTheme appTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: AppFonts.sourceSansPro,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
  headlineMedium: TextStyle(
    fontFamily: AppFonts.sourceSansPro,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
  titleMedium: TextStyle(
    fontFamily: AppFonts.sourceSansPro,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  bodyLarge: TextStyle(
    fontFamily: AppFonts.sourceSansPro,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  ),
  bodyMedium: TextStyle(
    fontFamily: AppFonts.sourceSansPro,
    fontSize: 14,
    color: AppColors.textPrimary,
  ),
  labelLarge: TextStyle(
    fontFamily: AppFonts.sourceSansPro,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  ),
);
