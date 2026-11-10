import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'core/theme/app_colors.dart';
import 'core/widgets/scooter_animation.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: _ScooterLab()),
);

class _ScooterLab extends StatelessWidget {
  const _ScooterLab();

  static const _canvasSize = 320.0;

  @override
  Widget build(BuildContext context) {
    const r = ScooterAnimation.cropRect;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: const Center(child: ScooterAnimation(width: 260)),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('اللوحة الكاملة (الإطار الأحمر = منطقة القص)'),
              ),
              SizedBox(
                width: _canvasSize,
                height: _canvasSize,
                child: Stack(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Lottie.asset(
                        ScooterAnimation.assetPath,
                        width: _canvasSize,
                        height: _canvasSize,
                      ),
                    ),
                    Positioned(
                      left: r.left * _canvasSize,
                      top: r.top * _canvasSize,
                      width: r.width * _canvasSize,
                      height: r.height * _canvasSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
