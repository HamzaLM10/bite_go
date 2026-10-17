import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/domain/entities/payment_method.dart';
import '../../../restaurants/domain/entities/restaurant.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({
    this.delay = const Duration(milliseconds: 800),
    this.stepDelay = const Duration(seconds: 5),
  });

  /// يحاكي زمن الشبكة؛ الاختبارات تمرّر Duration.zero.
  final Duration delay;
  final Duration stepDelay;
  int _counter = 1000;

  /// "قاعدة البيانات" الوهمية: نخزّن الطلبات بدل رميها.
  final Map<String, Order> _orders = {};

  @override
  Future<Order> placeOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
    required String address,
    required PaymentMethod paymentMethod,
  }) async {
    await Future<void>.delayed(delay);
    _counter++;
    final order = Order(
      id: 'BG-$_counter',
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      items: List.unmodifiable(items),
      deliveryFee: restaurant.deliveryFee,
      address: address,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      estimatedDeliveryAt: DateTime.now().add(
        Duration(minutes: restaurant.deliveryMinutes),
      ),
    );
    _orders[order.id] = order;
    return order;
  }

  @override
  Future<Order> getOrderById(String id) async {
    await Future<void>.delayed(delay);
    final order = _orders[id];
    if (order == null) {
      throw StateError('Order not found: $id');
    }
    return order;
  }

  @override
  Future<List<Order>> getOrders() async {
    await Future<void>.delayed(delay);
    // الـ Map يحفظ ترتيب الإدراج، فالمعكوس = الأحدث أولاً.
    return List.unmodifiable(_orders.values.toList().reversed);
  }

  @override
  Stream<Order> watchOrder(String id) async* {
    var order = await getOrderById(id);
    yield order;

    for (final status in OrderStatus.values.skip(order.status.index + 1)) {
      await Future<void>.delayed(stepDelay);
      order = order.copyWith(status: status);
      _orders[id] = order;
      yield order;
    }
  }
}