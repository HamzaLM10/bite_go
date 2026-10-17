import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeRestaurantRepository repo;

  setUp(() => repo = FakeRestaurantRepository(delay: Duration.zero));

  test('getRestaurants returns the 4 sample restaurants', () async {
    final result = await repo.getRestaurants();
    expect(result.length, 4);
  });

  test('getMenu returns only items of the requested restaurant', () async {
    final menu = await repo.getMenu('r1');
    expect(menu, isNotEmpty);
    expect(menu.every((m) => m.restaurantId == 'r1'), isTrue);
  });

  test('getRestaurantById throws for unknown id', () async {
    expect(() => repo.getRestaurantById('nope'), throwsStateError);
  });
}