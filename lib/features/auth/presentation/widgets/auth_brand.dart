import 'dart:math' as math;

import 'package:flutter/material.dart';

/// عرض الدراجة في الـ Splash. الـ Login يبدأ منه بالضبط ثم يصغّره،
/// لذلك يُحسب من مكان واحد حتى لا تختلف القيمتان.
double splashScooterWidth(double screenWidth) =>
    math.min(screenWidth * 0.65, 300);

/// اسم التطبيق: نمط واحد في الـ Splash والـ Login فيتطابق الإطاران.
class AuthBrandTitle extends StatelessWidget {
  const AuthBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Bite Go',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class AuthBrandTagline extends StatelessWidget {
  const AuthBrandTagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'طعامك المفضل يصلك أسرع',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white,
      ),
    );
  }
}