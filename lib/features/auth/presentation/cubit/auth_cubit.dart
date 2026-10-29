import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// صار HydratedCubit: تُستعاد الجلسة (مسجّل أو ضيف) بعد إغلاق التطبيق.
/// ملاحظة: هذا مناسب للمصادقة الوهمية فقط؛ في Back-end حقيقي يُحفظ
/// الـ token في flutter_secure_storage وليس في ملف JSON عادي.
class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthUnauthenticated());

  final AuthRepository _repository;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(email: email, password: password);
      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      if (isClosed) return;
      emit(AuthUnauthenticated(errorMessage: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(
        const AuthUnauthenticated(
          errorMessage: 'تعذّر تسجيل الدخول، حاول مرة أخرى',
        ),
      );
    }
  }

  void continueAsGuest() => emit(const AuthGuest());

  Future<void> logout() async {
    if (state is AuthAuthenticated) {
      await _repository.logout();
    }
    if (isClosed) return;
    emit(const AuthUnauthenticated());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    // أي بيانات غير مفهومة ← null ← يبدأ من AuthUnauthenticated (شاشة الدخول).
    switch (json['type']) {
      case 'authenticated':
        final user = json['user'];
        if (user is! Map) return null;
        final id = user['id'];
        final name = user['name'];
        final email = user['email'];
        if (id is! String || name is! String || email is! String) return null;
        return AuthAuthenticated(AppUser(id: id, name: name, email: email));
      case 'guest':
        return const AuthGuest();
      case 'unauthenticated':
        return const AuthUnauthenticated();
      default:
        return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return switch (state) {
      AuthAuthenticated(:final user) => {
          'type': 'authenticated',
          'user': {'id': user.id, 'name': user.name, 'email': user.email},
        },
      AuthGuest() => {'type': 'guest'},
      // نتعمد عدم حفظ errorMessage: رسالة خطأ قديمة لا يجب أن تظهر في تشغيل جديد.
      AuthUnauthenticated() => {'type': 'unauthenticated'},
      // Loading مؤقتة: null يعني "لا تكتب شيئاً"، فتبقى آخر حالة مستقرة محفوظة.
      AuthLoading() => null,
    };
  }
}