part of 'restaurants_bloc.dart';

sealed class RestaurantsState extends Equatable {
  const RestaurantsState();

  @override
  List<Object?> get props => [];
}

class RestaurantsInitial extends RestaurantsState {
  const RestaurantsInitial();
}

class RestaurantsLoading extends RestaurantsState {
  const RestaurantsLoading();
}

class RestaurantsLoaded extends RestaurantsState {
  const RestaurantsLoaded({
    required this.restaurants,
    this.query = '',
    this.cuisine,
    this.openOnly = false,
  });

  /// كل المطاعم كما جاءت من الـ Repository (لا تُفلتر هنا).
  final List<Restaurant> restaurants;
  final String query;
  final String? cuisine;
  final bool openOnly;

  /// المطابخ المتاحة لشرائح الفلترة (بدون تكرار، مرتبة).
  List<String> get cuisines =>
      restaurants.map((r) => r.cuisine).toSet().toList()..sort();

  /// القائمة المعروضة: مشتقة من المعايير الحالية.
  List<Restaurant> get visibleRestaurants {
    final q = query.trim().toLowerCase();
    return restaurants.where((r) {
      if (openOnly && !r.isOpen) return false;
      if (cuisine != null && r.cuisine != cuisine) return false;
      if (q.isNotEmpty &&
          !r.name.toLowerCase().contains(q) &&
          !r.cuisine.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  RestaurantsLoaded copyWith({String? query, bool? openOnly}) {
    return RestaurantsLoaded(
      restaurants: restaurants,
      query: query ?? this.query,
      cuisine: cuisine,
      openOnly: openOnly ?? this.openOnly,
    );
  }

  @override
  List<Object?> get props => [restaurants, query, cuisine, openOnly];
}

class RestaurantsError extends RestaurantsState {
  const RestaurantsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}