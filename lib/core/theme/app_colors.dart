import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // الهوية (ثابتة في الوضعين)
  static const primary = Color(0xFFFF6B35);
  static const secondary = Color(0xFF1F3D36);

  // الوضع الفاتح
  static const background = Color(0xFFFFF8F3);
  static const surface = Colors.white;
  static const textDark = Color(0xFF1E1E1E);
  static const textMuted = Color(0xFF6B7280);
  static const error = Color(0xFFD64545);

  // الوضع الداكن
  static const darkBackground = Color(0xFF121A18);
  static const darkSurface = Color(0xFF1C2825);
  static const textLight = Color(0xFFF1F3F2);
  static const textMutedDark = Color(0xFF9AA5A2);
  static const errorDark = Color(0xFFFF7B7B);
}