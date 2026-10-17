import 'package:bite_go/features/cart/domain/entities/cart_item.dart';
import 'package:bite_go/features/cart/domain/entities/payment_method.dart';
import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/tracking/data/repositories/fake_order_repository.dart';
import 'package:bite_go/features/tracking/domain/entities/order.dart';
import 'package:bite_go/features/tracking/domain/entities/order_status.dart';
import 'package:bite_go/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:bite_go/features/tracking/presentation/cubit/tracking_state.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Order> _placeOrder(FakeOrderRepository repo) async {
  final restaurants = FakeRestaurantRepository(delay: Duration.zero);
  final restaurant = await restaurants.getRestaurantById('r1');
  final menu = await restaurants.getMenu('r1');
  return repo.placeOrder(
    restaurant: restaurant,
    items: [CartItem(menuItem: menu.first, quantity: 1)],
    address: 'دمشق - المزة',
    paymentMethod: PaymentMethod.cash,
  );
}

TypeMatcher<TrackingLoaded> _loadedWith(OrderStatus status) =>
    isA<TrackingLoaded>().having((s) => s.order.status, 'status', status);

void main() {
  late FakeOrderRepository repo;

  setUp(() {
    repo = FakeOrderRepository(delay: Duration.zero, stepDelay: Duration.zero);
  });

  test('track emits loading then every status until delivered', () async {
    final order = await _placeOrder(repo);
    final cubit = TrackingCubit(repo);
    addTearDown(cubit.close);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<TrackingLoading>(),
        _loadedWith(OrderStatus.placed),
        _loadedWith(OrderStatus.preparing),
        _loadedWith(OrderStatus.onTheWay),
        _loadedWith(OrderStatus.delivered),
      ]),
    );
    cubit.track(order.id);
    await expectation;
  });

  test('track emits error for an unknown order', () async {
    final cubit = TrackingCubit(repo);
    addTearDown(cubit.close);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<TrackingLoading>(), isA<TrackingError>()]),
    );
    cubit.track('BG-0000');
    await expectation;
  });
}