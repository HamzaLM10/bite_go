import 'package:bite_go/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthCubit cubit;

  setUp(() {
    cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
    addTearDown(cubit.close);
  });

  test('الحالة الأولى: غير مسجّل بلا رسالة خطأ', () {
    expect(cubit.state, const AuthUnauthenticated());
    expect(cubit.state.hasAccess, isFalse);
  });

  test('login ناجح: Loading ثم Authenticated', () async {
    expectLater(
      cubit.stream,
      emitsInOrder([
        const AuthLoading(),
        isA<AuthAuthenticated>().having(
          (s) => s.user.name,
          'user.name',
          'hamza',
        ),
      ]),
    );

    await cubit.login(email: 'hamza@example.com', password: '123456');

    expect(cubit.state.hasAccess, isTrue);
  });

  test('login فاشل: Loading ثم Unauthenticated برسالة خطأ', () async {
    expectLater(
      cubit.stream,
      emitsInOrder([
        const AuthLoading(),
        isA<AuthUnauthenticated>().having(
          (s) => s.errorMessage,
          'errorMessage',
          isNotNull,
        ),
      ]),
    );

    await cubit.login(email: 'bad', password: '123456');

    expect(cubit.state.hasAccess, isFalse);
  });

  test('continueAsGuest يعطي Guest ويحق له الدخول', () {
    cubit.continueAsGuest();

    expect(cubit.state, const AuthGuest());
    expect(cubit.state.hasAccess, isTrue);
  });

  test('logout بعد الدخول يرجع Unauthenticated', () async {
    await cubit.login(email: 'hamza@example.com', password: '123456');

    expectLater(cubit.stream, emits(const AuthUnauthenticated()));

    await cubit.logout();
  });
}