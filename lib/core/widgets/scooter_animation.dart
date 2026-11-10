import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// دراجة التوصيل (Lottie من تصميم J Patel، انظر Credits في README).
///
/// ملف الأنيميشن لوحة مربعة 1080x1080 والدراجة في وسطها وبقيتها شفافة،
/// لذلك نقصّ المنطقة المرئية فقط. [width] هو عرض الدراجة المرئي لا عرض اللوحة.
class ScooterAnimation extends StatelessWidget {
  const ScooterAnimation({super.key, this.width = 240, this.animate = true});

  static const assetPath = 'assets/animations/scooter.json';

  /// صندوق التوصيل الخاص بنا يحل محل صندوق الملف الأصلي.

  /// معرّف صورة الصندوق داخل ملف الـ JSON (الطبقة box).

  /// المنطقة المرئية كنسب من اللوحة (يسار، أعلى، يمين، أسفل).
  static const cropRect = Rect.fromLTRB(0.29, 0.38, 0.84, 0.85);

  /// تستبدل صورة الصندوق وتترك بقية صور الأنيميشن كما هي (null = الافتراضي).

  final double width;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    // عرض اللوحة الكاملة بحيث يصير عرض المنطقة المقصوصة = width.
    final canvas = width / cropRect.width;
    final height = canvas * cropRect.height;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: canvas,
          maxWidth: canvas,
          minHeight: canvas,
          maxHeight: canvas,
          child: Transform.translate(
            offset: Offset(-cropRect.left * canvas, -cropRect.top * canvas),
            child: Lottie.asset(
              assetPath,
              width: canvas,
              height: canvas,
              animate: animate && !MediaQuery.disableAnimationsOf(context),
              repeat: true,
              frameRate: FrameRate.max,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('ScooterAnimation failed: $error');
                return Icon(
                  Icons.delivery_dining,
                  size: width / 2,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
