import 'dart:async';

import 'package:bite_go/core/router/app_router.dart';
import 'package:bite_go/core/router/stream_listenable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirect', () {
    test('غير مسجّل يطلب القائمة ← الدخول', () {
      expect(
        authRedirect(location: AppRoutes.restaurants, hasAccess: false),
        AppRoutes.login,
      );
    });

    test('غير مسجّل يطلب صفحة داخلية ← الدخول', () {
      expect(
        authRedirect(location: '/orders', hasAccess: false),
        AppRoutes.login,
      );
    });

    test('غير مسجّل في صفحة الدخول أو الـ splash ← لا تحويل', () {
      expect(
        authRedirect(location: AppRoutes.login, hasAccess: false),
        isNull,
      );
      expect(
        authRedirect(location: AppRoutes.splash, hasAccess: false),
        isNull,
      );
    });

    test('مسجّل أو ضيف يطلب صفحة الدخول ← القائمة', () {
      expect(
        authRedirect(location: AppRoutes.login, hasAccess: true),
        AppRoutes.restaurants,
      );
    });

    test('مسجّل أو ضيف يطلب صفحة داخلية أو الـ splash ← لا تحويل', () {
      expect(authRedirect(location: '/orders', hasAccess: true), isNull);
      expect(
        authRedirect(location: AppRoutes.splash, hasAccess: true),
        isNull,
      );
    });
  });

  test('StreamListenable يُخطر مستمعيه عند كل حدث في الـ stream', () async {
    final controller = StreamController<int>.broadcast();
    final listenable = StreamListenable(controller.stream);
    addTearDown(controller.close);
    addTearDown(listenable.dispose);

    var notifications = 0;
    listenable.addListener(() => notifications++);

    controller.add(1);
    controller.add(2);
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 2);
  });
}