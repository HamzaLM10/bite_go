import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// اسم العائلة كما هو مصرَّح به في pubspec.yaml (قسم fonts).
  static const String _fontFamily = 'Cairo';

  static ThemeData get light => _build(
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.textDark,
          onSurfaceVariant: AppColors.textMuted,
          error: AppColors.error,
        ),
        scaffoldBackground: AppColors.background,
        inputFill: Colors.white,
      );

  static ThemeData get dark => _build(
        scheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.textLight,
          onSurfaceVariant: AppColors.textMutedDark,
          error: AppColors.errorDark,
        ),
        scaffoldBackground: AppColors.darkBackground,
        inputFill: AppColors.darkSurface,
      );

  static ThemeData _build({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color inputFill,
  }) {
    // نبني على textTheme بنفس الـ brightness كي تأتي ألوان النص صحيحة
    final base = ThemeData(brightness: scheme.brightness, useMaterial3: true);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: _fontFamily,
      textTheme: base.textTheme.apply(fontFamily: _fontFamily),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}