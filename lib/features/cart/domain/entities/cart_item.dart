import 'package:equatable/equatable.dart';

import '../../../restaurants/domain/entities/menu_item.dart';

/// سطر في السلة: صنف + كميته.
class CartItem extends Equatable {
  const CartItem({required this.menuItem, required this.quantity});

  final MenuItem menuItem;
  final int quantity;

  double get total => menuItem.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(menuItem: menuItem, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [menuItem, quantity];
}