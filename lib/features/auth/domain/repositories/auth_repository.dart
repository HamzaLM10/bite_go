import '../entities/app_user.dart';

/// خطأ متوقع من المصادقة (بيانات غير صالحة...)، رسالته جاهزة للعرض.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  Future<AppUser> login({required String email, required String password});

  Future<void> logout();
}