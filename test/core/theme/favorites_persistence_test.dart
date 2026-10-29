import 'package:bite_go/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('المفضلة تُستعاد عند إنشاء FavoritesCubit جديد', () {
    final first = FavoritesCubit()
      ..toggle('r1')
      ..toggle('r3');
    addTearDown(first.close);

    final second = FavoritesCubit();
    addTearDown(second.close);

    expect(second.state.ids, {'r1', 'r3'});
    expect(second.state.isFavorite('r1'), isTrue);
    expect(second.state.isFavorite('r2'), isFalse);
  });

  test('إزالة مطعم من المفضلة تُحفظ أيضاً', () {
    final first = FavoritesCubit()
      ..toggle('r1')
      ..toggle('r1');
    addTearDown(first.close);

    final second = FavoritesCubit();
    addTearDown(second.close);

    expect(second.state.ids, isEmpty);
  });
}