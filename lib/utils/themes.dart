import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color surface = Color(0xFFF4F4F4);
  static const Color onSurface = Color(0xFF1D1A16);
  static const Color secondary = Color(0xFF908880);
  static const Color red = Color(0xFFAE4040);
  static const Color green = Color(0xFF7DAC6D);
  static const Color blue = Color(0xFF627B92);
}

final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.grey[800],
    colorScheme: ColorScheme.light(
      primary: AppColors.onSurface,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.red,
    ),
    fontFamily: GoogleFonts.roboto().fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
    ));

final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[300],
    colorScheme: ColorScheme.dark(
      primary: Colors.grey[300]!,
      secondary: Colors.grey[500]!,
      surface: Colors.grey[900]!,
      error: Colors.red,
    ),
    fontFamily: GoogleFonts.roboto().fontFamily,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
    ));