import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'favorites_state.dart';

/// صار HydratedCubit: تبقى المفضلة بعد إغلاق التطبيق.
class FavoritesCubit extends HydratedCubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  /// يضيف المطعم إن لم يكن مفضلاً، ويزيله إن كان.
  void toggle(String restaurantId) {
    // مجموعة جديدة دائماً، وإلا يرى Equatable نفس المجموعة فلا يصدر state.
    final ids = {...state.ids};
    if (!ids.remove(restaurantId)) ids.add(restaurantId);
    emit(FavoritesState(ids: ids));
  }

  @override
  FavoritesState? fromJson(Map<String, dynamic> json) {
    final raw = json['ids'];
    if (raw is! List) return null;
    // بعد القراءة من الملف تصل القائمة List<dynamic>، فنحوّلها لـ String صراحةً.
    return FavoritesState(ids: raw.cast<String>().toSet());
  }

  @override
  Map<String, dynamic>? toJson(FavoritesState state) => {
        'ids': state.ids.toList(),
      };
}