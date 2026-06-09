import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Shared
  static const Color teal = Color(0xFF00897B);
  static const Color greenLive = Color(0xFF4CAF50);
  static const Color speakerLabel = Color(0xFF1565C0);

  // Light theme
  static const Color lightBackground = Color(0xFFF0F4F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightSubtitleText = Color(0xFF2D3748);
  static const Color lightSubtitleBg = Color(0xFFE8EDF2);
  static const Color lightFieldBg = Color(0xFFE2E8F0);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F0F23);
  static const Color darkCard = Color(0xFF1A1A2E);
  static const Color darkSubtitleBg = Color(0xFF16213E);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkSubtitleText = Color(0xFF90A4AE);
  static const Color darkFieldBg = Color(0xFF1E1E3A);

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
      seedColor: teal,
      primary: teal,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightBackground,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal,
      primary: teal,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBackground,
    useMaterial3: true,
  );
}

enum FontSizeOption { small, medium, large }

enum SubtitlePosition { top, center, bottom }
