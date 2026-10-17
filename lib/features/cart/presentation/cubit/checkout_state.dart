import 'package:equatable/equatable.dart';

import '../../../restaurants/domain/entities/restaurant.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

final class CheckoutLoaded extends CheckoutState {
  const CheckoutLoaded(this.restaurant);

  final Restaurant restaurant;

  @override
  List<Object?> get props => [restaurant];
}

final class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}