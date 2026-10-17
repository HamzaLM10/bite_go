part of 'restaurants_bloc.dart';

sealed class RestaurantsEvent extends Equatable {
  const RestaurantsEvent();

  @override
  List<Object?> get props => [];
}

/// أول تحميل، وتُستعمل أيضاً لإعادة المحاولة.
class RestaurantsStarted extends RestaurantsEvent {
  const RestaurantsStarted();
}

class SearchQueryChanged extends RestaurantsEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// null = كل المطابخ.
class CuisineFilterChanged extends RestaurantsEvent {
  const CuisineFilterChanged(this.cuisine);

  final String? cuisine;

  @override
  List<Object?> get props => [cuisine];
}

class OpenOnlyToggled extends RestaurantsEvent {
  const OpenOnlyToggled();
}