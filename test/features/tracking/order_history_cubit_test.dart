import 'package:bite_go/features/cart/domain/entities/cart_item.dart';
import 'package:bite_go/features/cart/domain/entities/payment_method.dart';
import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/restaurants/domain/entities/restaurant.dart';
import 'package:bite_go/features/tracking/data/repositories/fake_order_repository.dart';
import 'package:bite_go/features/tracking/domain/entities/order.dart';
import 'package:bite_go/features/tracking/domain/repositories/order_repository.dart';
import 'package:bite_go/features/tracking/presentation/cubit/order_history_cubit.dart';
import 'package:bite_go/features/tracking/presentation/cubit/order_history_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThrowingOrderRepository implements OrderRepository {
  @override
  Future<List<Order>> getOrders() async => throw StateError('boom');

  @override
  Future<Order> getOrderById(String id) => throw UnimplementedError();

  @override
  Stream<Order> watchOrder(String id) => throw UnimplementedError();

  @override
  Future<Order> placeOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
    required String address,
    required PaymentMethod paymentMethod,
  }) =>
      throw UnimplementedError();
}

void main() {
  final restaurants = FakeRestaurantRepository(delay: Duration.zero);

  test('load emits Loading then Loaded with an empty list', () async {
    final cubit = OrderHistoryCubit(FakeOrderRepository(delay: Duration.zero));
    addTearDown(cubit.close);

    expectLater(
      cubit.stream,
      emitsInOrder([
        const OrderHistoryLoading(),
        const OrderHistoryLoaded([]),
      ]),
    );

    await cubit.load();
  });

  test('load emits the placed orders, newest first', () async {
    final repo = FakeOrderRepository(delay: Duration.zero);
    final restaurant = await restaurants.getRestaurantById('r1');
    final menu = await restaurants.getMenu('r1');
    final items = [CartItem(menuItem: menu.first, quantity: 1)];

    final a = await repo.placeOrder(
      restaurant: restaurant,
      items: items,
      address: 'x',
      paymentMethod: PaymentMethod.cash,
    );
    final b = await repo.placeOrder(
      restaurant: restaurant,
      items: items,
      address: 'x',
      paymentMethod: PaymentMethod.cash,
    );

    final cubit = OrderHistoryCubit(repo);
    addTearDown(cubit.close);

    expectLater(
      cubit.stream,
      emitsInOrder([
        const OrderHistoryLoading(),
        OrderHistoryLoaded([b, a]),
      ]),
    );

    await cubit.load();
  });

  test('load emits Error when the repository throws', () async {
    final cubit = OrderHistoryCubit(_ThrowingOrderRepository());
    addTearDown(cubit.close);

    expectLater(
      cubit.stream,
      emitsInOrder([
        const OrderHistoryLoading(),
        const OrderHistoryError('تعذّر تحميل الطلبات'),
      ]),
    );

    await cubit.load();
  });
}