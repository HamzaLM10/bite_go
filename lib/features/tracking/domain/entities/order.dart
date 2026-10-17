import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/domain/entities/payment_method.dart';
import 'order_status.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.deliveryFee,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    this.status = OrderStatus.placed,
    required this.estimatedDeliveryAt,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<CartItem> items;
  final double deliveryFee;
  final String address;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final OrderStatus status;
  final DateTime estimatedDeliveryAt;

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);
  double get total => subtotal + deliveryFee;

  Order copyWith({OrderStatus? status}) => Order(
    id: id,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    items: items,
    deliveryFee: deliveryFee,
    address: address,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
    status: status ?? this.status,
    estimatedDeliveryAt: estimatedDeliveryAt,
  );

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    restaurantName,
    items,
    deliveryFee,
    address,
    paymentMethod,
    createdAt,
    status,
  ];
}
