import 'package:bite_go/features/cart/domain/entities/cart_item.dart';
import 'package:bite_go/features/cart/domain/entities/payment_method.dart';
import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/tracking/data/repositories/fake_order_repository.dart';
import 'package:bite_go/features/tracking/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final restaurants = FakeRestaurantRepository(delay: Duration.zero);

  test('placeOrder يحسب الإجمالي بأجرة المطعم ويُنشئ id', () async {
    final repo = FakeOrderRepository(delay: Duration.zero);
    final restaurant = await restaurants.getRestaurantById('r1');
    final menu = await restaurants.getMenu('r1');

    final order = await repo.placeOrder(
      restaurant: restaurant,
      items: [CartItem(menuItem: menu.first, quantity: 2)],
      address: 'المزة، شارع الجلاء',
      paymentMethod: PaymentMethod.cash,
    );

    expect(order.id, isNotEmpty);
    expect(order.restaurantName, restaurant.name);
    expect(order.subtotal, menu.first.price * 2);
    expect(order.total, menu.first.price * 2 + restaurant.deliveryFee);
  });

  test('كل طلب له id مختلف', () async {
    final repo = FakeOrderRepository(delay: Duration.zero);
    final restaurant = await restaurants.getRestaurantById('r1');
    final menu = await restaurants.getMenu('r1');
    final items = [CartItem(menuItem: menu.first, quantity: 1)];

    final a = await repo.placeOrder(
      restaurant: restaurant,
      items: items,
      address: 'x',
      paymentMethod: PaymentMethod.card,
    );
    final b = await repo.placeOrder(
      restaurant: restaurant,
      items: items,
      address: 'x',
      paymentMethod: PaymentMethod.card,
    );

    expect(a.id, isNot(b.id));
  });

  test('getOrderById returns an order that was placed', () async {
    final repo = FakeOrderRepository(delay: Duration.zero);
    final restaurant = await FakeRestaurantRepository(delay: Duration.zero)
        .getRestaurantById('r1');
    final menu = await FakeRestaurantRepository(delay: Duration.zero)
        .getMenu('r1');

    final placed = await repo.placeOrder(
      restaurant: restaurant,
      items: [CartItem(menuItem: menu.first, quantity: 2)],
      address: 'دمشق - المزة',
      paymentMethod: PaymentMethod.cash,
    );

    final fetched = await repo.getOrderById(placed.id);

    expect(fetched, placed);
    expect(fetched.status, OrderStatus.placed);
  });

  test('getOrderById throws for an unknown id', () async {
    final repo = FakeOrderRepository(delay: Duration.zero);

    expect(() => repo.getOrderById('BG-0000'), throwsStateError);
  });
  test('getOrders returns an empty list when nothing was placed', () async {
    final repo = FakeOrderRepository(delay: Duration.zero);

    expect(await repo.getOrders(), isEmpty);
  });

  test('getOrders returns orders newest first', () async {
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

    final orders = await repo.getOrders();

    expect(orders.map((o) => o.id), [b.id, a.id]);
  });
}
