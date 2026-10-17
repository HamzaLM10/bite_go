import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';

part 'restaurants_event.dart';
part 'restaurants_state.dart';

/// يؤخر معالجة الـ events حتى يتوقف تدفقها، ويلغي ما قبل الأخير.
EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class RestaurantsBloc extends Bloc<RestaurantsEvent, RestaurantsState> {
  RestaurantsBloc(
    this._repository, {
    Duration searchDebounce = const Duration(milliseconds: 400),
  }) : super(const RestaurantsInitial()) {
    on<RestaurantsStarted>(_onStarted);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounce(searchDebounce),
    );
    on<CuisineFilterChanged>(_onCuisineChanged);
    on<OpenOnlyToggled>(_onOpenOnlyToggled);
  }

  final RestaurantRepository _repository;

  Future<void> _onStarted(
    RestaurantsStarted event,
    Emitter<RestaurantsState> emit,
  ) async {
    emit(const RestaurantsLoading());
    try {
      final restaurants = await _repository.getRestaurants();
      emit(RestaurantsLoaded(restaurants: restaurants));
    } catch (_) {
      emit(const RestaurantsError('تعذّر تحميل المطاعم. حاول مرة أخرى.'));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<RestaurantsState> emit,
  ) {
    final current = state;
    if (current is! RestaurantsLoaded) return;
    emit(current.copyWith(query: event.query));
  }

  void _onCuisineChanged(
    CuisineFilterChanged event,
    Emitter<RestaurantsState> emit,
  ) {
    final current = state;
    if (current is! RestaurantsLoaded) return;
    emit(RestaurantsLoaded(
      restaurants: current.restaurants,
      query: current.query,
      cuisine: event.cuisine,
      openOnly: current.openOnly,
    ));
  }

  void _onOpenOnlyToggled(
    OpenOnlyToggled event,
    Emitter<RestaurantsState> emit,
  ) {
    final current = state;
    if (current is! RestaurantsLoaded) return;
    emit(current.copyWith(openOnly: !current.openOnly));
  }
}