import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

sealed class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {
  const OrderHistoryInitial();
}

class OrderHistoryLoading extends OrderHistoryState {
  const OrderHistoryLoading();
}

class OrderHistoryLoaded extends OrderHistoryState {
  const OrderHistoryLoaded(this.orders);

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryError extends OrderHistoryState {
  const OrderHistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}