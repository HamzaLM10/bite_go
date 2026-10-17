import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    // نقرأ الوضع الفعلي المعروض الآن (وليس ThemeMode)، فيعمل الزر صحيحاً
    // حتى لو كان التطبيق على system والهاتف داكناً.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => context
          .read<ThemeCubit>()
          .setMode(isDark ? ThemeMode.light : ThemeMode.dark),
    );
  }
}