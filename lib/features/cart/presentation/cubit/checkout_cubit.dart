import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../restaurants/domain/repositories/restaurant_repository.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._repository) : super(const CheckoutInitial());

  final RestaurantRepository _repository;

  Future<void> load(String restaurantId) async {
    emit(const CheckoutLoading());
    try {
      final restaurant = await _repository.getRestaurantById(restaurantId);
      if (isClosed) return;
      emit(CheckoutLoaded(restaurant));
    } catch (_) {
      if (isClosed) return;
      emit(const CheckoutError('تعذّر تحميل بيانات التوصيل. حاول مرة أخرى.'));
    }
  }
}