import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.delay = const Duration(milliseconds: 800)});

  final Duration delay;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);

    final cleanEmail = email.trim();
    if (!_emailPattern.hasMatch(cleanEmail)) {
      throw const AuthException('البريد الإلكتروني غير صالح');
    }
    if (password.length < 6) {
      throw const AuthException('كلمة المرور يجب ألا تقل عن 6 أحرف');
    }

    return AppUser(
      id: cleanEmail.toLowerCase(),
      name: cleanEmail.split('@').first,
      email: cleanEmail,
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(delay);
  }
}