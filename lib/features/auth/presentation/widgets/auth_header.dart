import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/scooter_animation.dart';
import 'auth_brand.dart';

const _headerScooterMaxWidth = 240.0;
const _curveDepth = 36.0;

/// ترويسة الـ Login. [progress] = 0 تطابق شاشة الـ Splash (برتقالي كامل
/// والمحتوى في المنتصف)، و1 هي الترويسة المنحنية النهائية.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final fromWidth = splashScooterWidth(size.width);
    final toWidth = math.min(size.width * 0.6, _headerScooterMaxWidth);

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;

        return ClipPath(
          clipper: _CurvedBottomClipper(_curveDepth * t),
          child: ConstrainedBox(
            // الارتفاع الأدنى يبدأ بكامل الشاشة ثم يتلاشى؛ فيتوسّط المحتوى
            // أولاً (كالـ Splash) ثم ينتقل للأعلى مع تقلّص الارتفاع.
            constraints: BoxConstraints(minHeight: size.height * (1 - t)),
            child: ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: EdgeInsets.only(
                  top: (topInset + AppSpacing.lg) * t,
                  bottom: (_curveDepth + AppSpacing.md) * t,
                ),
                child: Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScooterAnimation(width: lerpDouble(fromWidth, toWidth, t)!),
                      SizedBox(
                        height: lerpDouble(AppSpacing.lg, AppSpacing.sm, t),
                      ),
                      const AuthBrandTitle(),
                      if (t < 1)
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: 1 - t, // ينكمش الشعار حتى يختفي
                            child: Opacity(
                              opacity: 1 - t,
                              child: const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.sm),
                                child: AuthBrandTagline(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// يقصّ الحافة السفلية على شكل قوس عمقه [depth] (صفر = حافة مستقيمة).
class _CurvedBottomClipper extends CustomClipper<Path> {
  const _CurvedBottomClipper(this.depth);

  final double depth;

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - depth)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + depth, // قمة القوس تقع عند size.height
        size.width,
        size.height - depth,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CurvedBottomClipper oldClipper) =>
      oldClipper.depth != depth;
}