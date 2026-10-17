import 'package:equatable/equatable.dart';

import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';

sealed class RestaurantDetailsState extends Equatable {
  const RestaurantDetailsState();

  @override
  List<Object?> get props => [];
}

class RestaurantDetailsInitial extends RestaurantDetailsState {
  const RestaurantDetailsInitial();
}

class RestaurantDetailsLoading extends RestaurantDetailsState {
  const RestaurantDetailsLoading();
}

class RestaurantDetailsLoaded extends RestaurantDetailsState {
  const RestaurantDetailsLoaded({required this.restaurant, required this.menu});

  final Restaurant restaurant;
  final List<MenuItem> menu;

  /// المنيو مجمّعاً حسب الفئة، لعرضه بأقسام في الصفحة.
  Map<String, List<MenuItem>> get menuByCategory {
    final grouped = <String, List<MenuItem>>{};
    for (final item in menu) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  @override
  List<Object?> get props => [restaurant, menu];
}

class RestaurantDetailsError extends RestaurantDetailsState {
  const RestaurantDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}