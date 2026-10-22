import 'package:bite_go/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_state.dart';
import 'package:bite_go/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthCubit cubit;

  setUp(() {
    cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
    addTearDown(cubit.close);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
  }

  final emailField = find.byType(TextFormField).at(0);
  final passwordField = find.byType(TextFormField).at(1);
  final loginButton = find.widgetWithText(FilledButton, 'تسجيل الدخول');

  testWidgets('تعرض الحقلين وزر الدخول وزر الضيف', (tester) async {
    await pumpPage(tester);

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(loginButton, findsOneWidget);
    expect(find.text('المتابعة كضيف'), findsOneWidget);
  });

  testWidgets('الحقول الفارغة تُظهر رسائل التحقق ولا تُرسل شيئاً',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('أدخل بريدك الإلكتروني'), findsOneWidget);
    expect(find.text('أدخل كلمة المرور'), findsOneWidget);
    expect(cubit.state, const AuthUnauthenticated());
  });

  testWidgets('بريد غير صالح يعرض رسالة الخطأ من الـ Repository',
      (tester) async {
    await pumpPage(tester);

    await tester.enterText(emailField, 'bad');
    await tester.enterText(passwordField, '123456');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('البريد الإلكتروني غير صالح'), findsOneWidget);
    expect(cubit.state.hasAccess, isFalse);
  });

  testWidgets('بيانات صحيحة تجعل الحالة Authenticated', (tester) async {
    await pumpPage(tester);

    await tester.enterText(emailField, 'hamza@example.com');
    await tester.enterText(passwordField, '123456');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(cubit.state, isA<AuthAuthenticated>());
  });

  testWidgets('زر الضيف يجعل الحالة Guest', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('المتابعة كضيف'));
    await tester.pump();

    expect(cubit.state, const AuthGuest());
  });
}