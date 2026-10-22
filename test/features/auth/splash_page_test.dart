import 'package:bite_go/core/router/app_router.dart';
import 'package:bite_go/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('الشاشة الترحيبية تظهر ثم تنتقل للقائمة بعد انتهاء الأنيميشن',
      (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.restaurants,
          builder: (context, state) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Bite Go'), findsOneWidget);
    expect(find.text('home'), findsNothing);

    // ينتهي الأنيميشن (1400ms) فيُسجَّل مؤقّت الانتظار (500ms).
    await tester.pump(const Duration(seconds: 2));
    // نمرّر وقت المؤقّت صراحةً لأن pumpAndSettle لا ينتظر Timer.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}