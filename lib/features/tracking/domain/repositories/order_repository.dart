import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/domain/entities/payment_method.dart';
import '../../../restaurants/domain/entities/restaurant.dart';
import '../entities/order.dart';

abstract interface class OrderRepository {
  Future<Order> placeOrder({
    required Restaurant restaurant,
    required List<CartItem> items,
    required String address,
    required PaymentMethod paymentMethod,
  });

  Future<Order> getOrderById(String id);

  /// كل الطلبات، الأحدث أولاً.
  Future<List<Order>> getOrders();

  Stream<Order> watchOrder(String id);
}