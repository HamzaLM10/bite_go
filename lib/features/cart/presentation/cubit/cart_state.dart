import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

class CartState extends Equatable {
  const CartState({this.restaurantId, this.items = const []});

  /// مطعم السلة الحالي، و null إذا كانت فارغة.
  final String? restaurantId;
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;
  int get totalCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0.0, (sum, i) => sum + i.total);

  @override
  List<Object?> get props => [restaurantId, items];
}