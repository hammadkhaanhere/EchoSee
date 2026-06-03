import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light theme
  static const Color navyBlue = Color(0xFF0D1B2A);
  static const Color teal = Color(0xFF00897B);
  static const Color greenLive = Color(0xFF4CAF50);
  static const Color cardBackground = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color subtitleBackground = Color(0xFFFFFFFF);
  static const Color speakerLabel = Color(0xFF1565C0);
  static const Color subtitleText = Color(0xFF212121);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF1A1A2E);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkSubtitleBg = Color(0xFF16213E);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkSubtitleText = Color(0xFF90A4AE);

  // Subtitle color palette
  static const List<Color> subtitleColorPalette = [
    Color(0xFFFFFFFF),
    Color(0xFFFFF176),
    Color(0xFF81D4FA),
    Color(0xFFA5D6A7),
    Color(0xFFFFCC80),
    Color(0xFFCE93D8),
  ];

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: navyBlue,
      primary: teal,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: navyBlue,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: darkBackground,
      primary: teal,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBackground,
    useMaterial3: true,
  );
}

enum FontSizeOption { small, medium, large }

enum SubtitlePosition { top, center, bottom }
