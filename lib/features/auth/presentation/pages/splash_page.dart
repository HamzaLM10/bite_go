import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/scooter_animation.dart';
import '../widgets/auth_brand.dart';

const _animationDuration = Duration(milliseconds: 2200);
const _holdAfterAnimation = Duration(milliseconds: 1200);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drive;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animationDuration);

    // الدراجة: أول 55% من الوقت، تدخل بسرعة ثم تبطئ حتى تقف (easeOutCubic).
    _drive = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );

    // النص: من 55% إلى 100% (يظهر ويصعد قليلاً من الأسفل).
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1, curve: Curves.easeOut),
    );
    _textFade = textCurve;
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(textCurve);

    _run();
  }

  Future<void> _run() async {
    await _controller.forward();
    await Future<void>.delayed(_holdAfterAnimation);
    if (!mounted) return;
    context.go(AppRoutes.restaurants);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scooterWidth = splashScooterWidth(screenWidth);
    // المسافة التي تجعل الدراجة خارج الشاشة تماماً من اليمين عند البداية.
    final startDx = screenWidth / 2 + scooterWidth / 2 + AppSpacing.md;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _drive,
              builder: (context, child) => Transform.translate(
                offset: Offset((1 - _drive.value) * startDx, 0),
                child: child,
              ),
              child: ScooterAnimation(width: scooterWidth),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: const Column(
                  children: [
                    AuthBrandTitle(),
                    SizedBox(height: AppSpacing.sm),
                    AuthBrandTagline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}