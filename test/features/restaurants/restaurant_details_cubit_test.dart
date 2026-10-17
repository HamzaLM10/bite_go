import 'package:flutter_test/flutter_test.dart';

import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:bite_go/features/restaurants/domain/entities/restaurant.dart';
import 'package:bite_go/features/restaurants/domain/repositories/restaurant_repository.dart';
import 'package:bite_go/features/restaurants/presentation/cubit/restaurant_details_cubit.dart';
import 'package:bite_go/features/restaurants/presentation/cubit/restaurant_details_state.dart';

class _ThrowingRepository implements RestaurantRepository {
  @override
  Future<List<Restaurant>> getRestaurants() => throw Exception('boom');

  @override
  Future<Restaurant> getRestaurantById(String id) => throw Exception('boom');

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) => throw Exception('boom');
}

void main() {
  test('load emits Loading then Loaded with restaurant and menu', () async {
    final cubit = RestaurantDetailsCubit(
      FakeRestaurantRepository(delay: Duration.zero),
    );
    final states = <RestaurantDetailsState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load('r1');
    await Future<void>.delayed(Duration.zero);

    expect(states[0], isA<RestaurantDetailsLoading>());
    final loaded = states[1] as RestaurantDetailsLoaded;
    expect(loaded.restaurant.id, 'r1');
    expect(loaded.menu, isNotEmpty);
    expect(loaded.menu.every((m) => m.restaurantId == 'r1'), isTrue);

    await sub.cancel();
    await cubit.close();
  });

  test('load emits Error when the repository throws', () async {
    final cubit = RestaurantDetailsCubit(_ThrowingRepository());
    final states = <RestaurantDetailsState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.load('r1');
    await Future<void>.delayed(Duration.zero);

    expect(states[0], isA<RestaurantDetailsLoading>());
    expect(states[1], isA<RestaurantDetailsError>());

    await sub.cancel();
    await cubit.close();
  });
}