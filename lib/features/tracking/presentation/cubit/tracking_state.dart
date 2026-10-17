import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

sealed class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

class TrackingLoaded extends TrackingState {
  const TrackingLoaded(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

class TrackingError extends TrackingState {
  const TrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}