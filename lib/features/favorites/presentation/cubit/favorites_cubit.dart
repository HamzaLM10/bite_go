import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  /// يضيف المطعم إن لم يكن مفضلاً، ويزيله إن كان.
  void toggle(String restaurantId) {
    // مجموعة جديدة دائماً، وإلا يرى Equatable نفس المجموعة فلا يصدر state.
    final ids = {...state.ids};
    if (!ids.remove(restaurantId)) ids.add(restaurantId);
    emit(FavoritesState(ids: ids));
  }
}