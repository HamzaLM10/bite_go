import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../restaurants/domain/entities/menu_item.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_state.dart';

enum AddToCartResult { added, differentRestaurant }

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  AddToCartResult add(MenuItem item) {
    final current = state;
    if (!current.isEmpty && current.restaurantId != item.restaurantId) {
      return AddToCartResult.differentRestaurant;
    }

    final items = [...current.items];
    final index = items.indexWhere((i) => i.menuItem.id == item.id);
    if (index == -1) {
      items.add(CartItem(menuItem: item, quantity: 1));
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    }
    emit(CartState(restaurantId: item.restaurantId, items: items));
    return AddToCartResult.added;
  }

  /// تفريغ السلة والبدء بصنف من مطعم جديد.
  void replaceWith(MenuItem item) {
    emit(CartState(
      restaurantId: item.restaurantId,
      items: [CartItem(menuItem: item, quantity: 1)],
    ));
  }

  void decrement(String menuItemId) {
    final items = [...state.items];
    final index = items.indexWhere((i) => i.menuItem.id == menuItemId);
    if (index == -1) return;

    if (items[index].quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] =
          items[index].copyWith(quantity: items[index].quantity - 1);
    }
    _emitItems(items);
  }

  void remove(String menuItemId) {
    _emitItems(
      state.items.where((i) => i.menuItem.id != menuItemId).toList(),
    );
  }

  void clear() => emit(const CartState());

  /// إذا فرغت السلة نعيد restaurantId إلى null لتقبل أي مطعم.
  void _emitItems(List<CartItem> items) {
    if (items.isEmpty) {
      emit(const CartState());
    } else {
      emit(CartState(restaurantId: state.restaurantId, items: items));
    }
  }
}