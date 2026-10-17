import 'package:flutter_test/flutter_test.dart';

import 'package:bite_go/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:bite_go/features/favorites/presentation/cubit/favorites_state.dart';

void main() {
  test('toggle adds then removes a restaurant', () async {
    final cubit = FavoritesCubit();
    addTearDown(cubit.close);

    // يُنشأ قبل الاستدعاء لأن الـ stream من نوع broadcast.
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const FavoritesState(ids: {'r1'}),
        const FavoritesState(),
      ]),
    );

    cubit.toggle('r1');
    cubit.toggle('r1');
    await expectation;
  });

  test('restaurants are toggled independently', () {
    final cubit = FavoritesCubit();
    addTearDown(cubit.close);

    cubit.toggle('r1');
    cubit.toggle('r2');
    cubit.toggle('r1');

    expect(cubit.state.isFavorite('r1'), isFalse);
    expect(cubit.state.isFavorite('r2'), isTrue);
  });
}