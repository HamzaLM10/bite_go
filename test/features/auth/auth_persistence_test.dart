import 'package:bite_go/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:bite_go/features/auth/domain/entities/app_user.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bite_go/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

AuthCubit _newCubit() {
  final cubit = AuthCubit(FakeAuthRepository(delay: Duration.zero));
  addTearDown(cubit.close);
  return cubit;
}

void main() {
  test('جلسة المسجّل تُستعاد عند إنشاء AuthCubit جديد', () async {
    final first = _newCubit();
    await first.login(email: 'Hamza@Example.com', password: '123456');

    // نسخة جديدة تحاكي تشغيل التطبيق من جديد.
    final second = _newCubit();

    expect(
      second.state,
      const AuthAuthenticated(
        AppUser(
          id: 'hamza@example.com',
          name: 'Hamza',
          email: 'Hamza@Example.com',
        ),
      ),
    );
    expect(second.state.hasAccess, isTrue);
  });

  test('جلسة الضيف تُستعاد', () {
    _newCubit().continueAsGuest();

    final second = _newCubit();

    expect(second.state, const AuthGuest());
    expect(second.state.hasAccess, isTrue);
  });

  test('بعد تسجيل الخروج لا تُستعاد الجلسة', () async {
    final first = _newCubit();
    await first.login(email: 'hamza@example.com', password: '123456');
    await first.logout();

    final second = _newCubit();

    expect(second.state, const AuthUnauthenticated());
    expect(second.state.hasAccess, isFalse);
  });

  test('رسالة خطأ الدخول لا تُحفظ', () async {
    final first = _newCubit();
    await first.login(email: 'bad', password: '123456');
    expect(
      (first.state as AuthUnauthenticated).errorMessage,
      isNotNull,
    );

    final second = _newCubit();

    // مقارنة Equatable: errorMessage يجب أن تكون null.
    expect(second.state, const AuthUnauthenticated());
  });

  test('بيانات محفوظة ناقصة أو غير معروفة تُتجاهل', () {
    // مسجّل بلا مستخدم.
    HydratedBloc.storage.write('AuthCubit', {'type': 'authenticated'});
    expect(_newCubit().state, const AuthUnauthenticated());

    // نوع غير معروف.
    HydratedBloc.storage.write('AuthCubit', {'type': 'admin'});
    expect(_newCubit().state, const AuthUnauthenticated());
  });
}