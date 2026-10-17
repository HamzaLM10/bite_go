import 'package:flutter_test/flutter_test.dart';

import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/restaurants/presentation/bloc/restaurants_bloc.dart';

void main() {
  late FakeRestaurantRepository repo;
  late RestaurantsBloc bloc;

  setUp(() {
    repo = FakeRestaurantRepository(delay: Duration.zero);
    bloc = RestaurantsBloc(repo, searchDebounce: Duration.zero);
  });

  tearDown(() => bloc.close());

  /// يشغّل التحميل وينتظر أول Loaded.
  Future<RestaurantsLoaded> loadAll() async {
    bloc.add(const RestaurantsStarted());
    return await bloc.stream.firstWhere((s) => s is RestaurantsLoaded)
        as RestaurantsLoaded;
  }

  test('RestaurantsStarted emits Loading then Loaded', () async {
    final expected = await repo.getRestaurants();

    final future = expectLater(
      bloc.stream,
      emitsInOrder([
        const RestaurantsLoading(),
        RestaurantsLoaded(restaurants: expected),
      ]),
    );

    bloc.add(const RestaurantsStarted());
    await future;
  });

  test('SearchQueryChanged filters by name', () async {
    final loaded = await loadAll();
    final target = loaded.restaurants.first;

    bloc.add(SearchQueryChanged(target.name));
    final result = await bloc.stream.firstWhere(
      (s) => s is RestaurantsLoaded && s.query == target.name,
    ) as RestaurantsLoaded;

    expect(result.visibleRestaurants, contains(target));
    expect(
      result.visibleRestaurants.every((r) => r.name.contains(target.name) ||
          r.cuisine.contains(target.name)),
      isTrue,
    );
  });

  test('CuisineFilterChanged keeps only that cuisine', () async {
    final loaded = await loadAll();
    final cuisine = loaded.restaurants.first.cuisine;

    bloc.add(CuisineFilterChanged(cuisine));
    final result = await bloc.stream.firstWhere(
      (s) => s is RestaurantsLoaded && s.cuisine == cuisine,
    ) as RestaurantsLoaded;

    expect(result.visibleRestaurants.every((r) => r.cuisine == cuisine), isTrue);
  });

  test('OpenOnlyToggled hides closed restaurants', () async {
    final loaded = await loadAll();

    bloc.add(const OpenOnlyToggled());
    final result = await bloc.stream.firstWhere(
      (s) => s is RestaurantsLoaded && s.openOnly,
    ) as RestaurantsLoaded;

    expect(result.visibleRestaurants.every((r) => r.isOpen), isTrue);
    expect(result.visibleRestaurants.length,
        lessThan(loaded.restaurants.length)); // r3 مغلق عمداً
  });
}