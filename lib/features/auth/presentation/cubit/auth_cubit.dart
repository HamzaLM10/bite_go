import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
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
}