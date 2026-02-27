import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // 1. Light Theme
  static ThemeData get orangeTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
    );
  }

  // 2. Modern Deep Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primarySky,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkForeground,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder),
      iconTheme: const IconThemeData(color: AppColors.darkForeground),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkForeground),
        bodyMedium: TextStyle(color: AppColors.darkForeground),
        titleLarge: TextStyle(color: AppColors.darkForeground, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }
}
