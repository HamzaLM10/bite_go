import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._repository) : super(const TrackingInitial());

  final OrderRepository _repository;
  StreamSubscription<Order>? _subscription;

  void track(String orderId) {
    _subscription?.cancel();
    emit(const TrackingLoading());
    _subscription = _repository.watchOrder(orderId).listen(
          (order) => emit(TrackingLoaded(order)),
          onError: (_) => emit(const TrackingError('تعذّر تحميل الطلب')),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}