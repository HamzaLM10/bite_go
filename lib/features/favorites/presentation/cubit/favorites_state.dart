import 'package:equatable/equatable.dart';

/// نخزّن ids المطاعم فقط، فالمطعم نفسه يأتي من الـ Repository.
class FavoritesState extends Equatable {
  const FavoritesState({this.ids = const <String>{}});

  final Set<String> ids;

  /// مشتق (getter) ولا يُخزَّن.
  bool isFavorite(String restaurantId) => ids.contains(restaurantId);

  @override
  List<Object?> get props => [ids];
}