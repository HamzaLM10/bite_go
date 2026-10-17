import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/restaurant_repository.dart';
import 'restaurant_details_state.dart';

class RestaurantDetailsCubit extends Cubit<RestaurantDetailsState> {
  RestaurantDetailsCubit(this._repository)
      : super(const RestaurantDetailsInitial());

  final RestaurantRepository _repository;

  Future<void> load(String restaurantId) async {
    emit(const RestaurantDetailsLoading());
    try {
      // الطلبان مستقلان، فننفذهما بالتوازي بدل الانتظار لكل واحد.
      final (restaurant, menu) = await (
        _repository.getRestaurantById(restaurantId),
        _repository.getMenu(restaurantId),
      ).wait;

      if (isClosed) return;
      emit(RestaurantDetailsLoaded(restaurant: restaurant, menu: menu));
    } catch (_) {
      if (isClosed) return;
      emit(const RestaurantDetailsError('تعذّر تحميل المطعم. حاول مرة أخرى.'));
    }
  }
}