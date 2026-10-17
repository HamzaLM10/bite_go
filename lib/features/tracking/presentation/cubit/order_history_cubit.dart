import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/order_repository.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(this._repository) : super(const OrderHistoryInitial());

  final OrderRepository _repository;

  Future<void> load() async {
    emit(const OrderHistoryLoading());
    try {
      final orders = await _repository.getOrders();
      if (isClosed) return;
      emit(OrderHistoryLoaded(orders));
    } catch (_) {
      if (isClosed) return;
      emit(const OrderHistoryError('تعذّر تحميل الطلبات'));
    }
  }
}