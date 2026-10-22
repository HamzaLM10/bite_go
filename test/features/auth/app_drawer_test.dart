import 'package:bite_go/core/router/app_router.dart';
import 'package:bite_go/core/theme/theme_cubit.dart';
import 'package:bite_go/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_state.dart';
import 'package:bite_go/features/auth/presentation/widgets/app_drawer.dart';
import 'package:bite_go/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late AuthCubit authCubit;
  late CartCubit cartCubit;
  late ThemeCubit themeCubit;

  final item = MenuItem(
    id: 'm1',
    restaurantId: 'r1',
    name: 'برغر',
    description: 'وصف',
    price: 10000,
    imageUrl: '',
    category: 'برغر',
  );

  setUp(() {
    authCubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
    cartCubit = CartCubit();
    themeCubit = ThemeCubit();
    addTearDown(authCubit.close);
    addTearDown(cartCubit.close);
    addTearDown(themeCubit.close);
  });

  Future<void> signIn(WidgetTester tester) async {
    await tester.runAsync(
      () => authCubit.login(email: 'hamza@example.com', password: '123456'),
    );
  }

  /// يبني صفحة رئيسية بديلة تحمل الـ Drawer ثم يفتحه.
  Future<void> openDrawer(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(title: const Text('home')),
          ),
        ),
        GoRoute(
          path: AppRoutes.orders,
          builder: (_, _) => const Scaffold(body: Text('orders page')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: cartCubit),
          BlocProvider.value(value: themeCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  final dialogLogoutButton = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(FilledButton, 'تسجيل الخروج'),
  );

  testWidgets('المستخدم المسجّل: الاسم والبريد وزر الخروج', (tester) async {
    await signIn(tester);
    await openDrawer(tester);

    expect(find.text('hamza'), findsOneWidget);
    expect(find.text('hamza@example.com'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsNothing);
  });

  testWidgets('الضيف: "زائر" وزر تسجيل الدخول بدل الخروج', (tester) async {
    authCubit.continueAsGuest();
    await openDrawer(tester);

    expect(find.text('زائر'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsNothing);
  });

  testWidgets('"طلباتي" يغلق الـ Drawer ويفتح صفحة الطلبات', (tester) async {
    authCubit.continueAsGuest();
    await openDrawer(tester);

    await tester.tap(find.text('طلباتي'));
    await tester.pumpAndSettle();

    expect(find.text('orders page'), findsOneWidget);
  });

  testWidgets('مفتاح الوضع الداكن يغيّر ThemeCubit', (tester) async {
    authCubit.continueAsGuest();
    await openDrawer(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(themeCubit.state, ThemeMode.dark);
  });

  testWidgets('تأكيد الخروج يُخرج المستخدم ويفرّغ السلة', (tester) async {
    await signIn(tester);
    cartCubit.add(item);
    await openDrawer(tester);

    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();

    expect(
      find.text('هل تريد تسجيل الخروج؟ سيتم تفريغ سلتك الحالية.'),
      findsOneWidget,
    );

    await tester.tap(dialogLogoutButton);
    await tester.pumpAndSettle();

    expect(authCubit.state, const AuthUnauthenticated());
    expect(cartCubit.state.isEmpty, isTrue);
  });

  testWidgets('إلغاء الحوار يُبقي المستخدم والسلة', (tester) async {
    await signIn(tester);
    cartCubit.add(item);
    await openDrawer(tester);

    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(authCubit.state, isA<AuthAuthenticated>());
    expect(cartCubit.state.isEmpty, isFalse);
  });
}