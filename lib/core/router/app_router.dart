import 'package:go_router/go_router.dart';

import 'package:bite_go/features/cart/presentation/pages/cart_page.dart';
import 'package:bite_go/features/restaurants/presentation/pages/restaurant_details_page.dart';
import 'package:bite_go/features/restaurants/presentation/pages/restaurants_page.dart';
import 'package:bite_go/features/cart/presentation/pages/checkout_page.dart';
import 'package:bite_go/features/tracking/presentation/pages/order_history_page.dart';
import 'package:bite_go/features/tracking/presentation/pages/tracking_page.dart';

abstract final class AppRoutes {
  static const restaurants = '/';
  static const restaurantDetails = '/restaurants/:id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const tracking = '/orders/:id/tracking';
  static String trackingPath(String id) => '/orders/$id/tracking';

  static String restaurantPath(String id) => '/restaurants/$id';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.restaurants,
  routes: [
    GoRoute(
      path: AppRoutes.restaurants,
      builder: (context, state) => const RestaurantsPage(),
    ),
    GoRoute(
      path: AppRoutes.restaurantDetails,
      builder: (context, state) => RestaurantDetailsPage(
        restaurantId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrderHistoryPage(),
    ),
    GoRoute(
      path: AppRoutes.tracking,
      builder: (context, state) => TrackingPage(
        orderId: state.pathParameters['id']!,
      ),
    ),
  ],
);