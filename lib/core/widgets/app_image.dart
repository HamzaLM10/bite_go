import 'package:flutter/material.dart';

/// يعرض صورة من الإنترنت (إن بدأ المصدر بـ http) أو من الـ assets (مسار)،
/// مع بديل موحّد (أيقونة على خلفية خافتة) عند فشل التحميل.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    required this.fallbackIcon,
    this.fallbackIconSize = 24,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String source;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isNetwork => source.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final placeholder = SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(child: Icon(fallbackIcon, size: fallbackIconSize)),
      ),
    );

    return _isNetwork
        ? Image.network(
            source,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => placeholder,
          )
        : Image.asset(
            source,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, error, _) {
              debugPrint('AppImage failed: $source -> $error');
              return placeholder;
            },
          );
  }
}
