import 'package:bite_go/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:bite_go/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository(delay: Duration.zero));

  test('login يرجع مستخدماً اسمه من الجزء الذي قبل @', () async {
    final user = await repository.login(
      email: 'hamza@example.com',
      password: '123456',
    );

    expect(user.name, 'hamza');
    expect(user.email, 'hamza@example.com');
  });

  test('login يرمي AuthException لبريد غير صالح', () {
    expect(
      repository.login(email: 'not-an-email', password: '123456'),
      throwsA(isA<AuthException>()),
    );
  });

  test('login يرمي AuthException لكلمة مرور قصيرة', () {
    expect(
      repository.login(email: 'a@b.com', password: '123'),
      throwsA(isA<AuthException>()),
    );
  });

  test('logout يكتمل بلا خطأ', () async {
    await repository.logout();
  });
}