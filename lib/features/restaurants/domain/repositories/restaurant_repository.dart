import '../entities/menu_item.dart';
import '../entities/restaurant.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<Restaurant> getRestaurantById(String id);
  Future<List<MenuItem>> getMenu(String restaurantId);
}