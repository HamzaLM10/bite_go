import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:bite_go/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bite_go/features/auth/presentation/pages/login_page.dart';
import 'package:bite_go/features/auth/presentation/pages/splash_page.dart';
import 'package:bite_go/features/cart/presentation/pages/cart_page.dart';
import 'package:bite_go/features/restaurants/presentation/pages/restaurant_details_page.dart';
import 'package:bite_go/features/restaurants/presentation/pages/restaurants_page.dart';
import 'package:bite_go/features/cart/presentation/pages/checkout_page.dart';
import 'package:bite_go/features/tracking/presentation/pages/order_history_page.dart';
import 'package:bite_go/features/tracking/presentation/pages/tracking_page.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const restaurants = '/';
  static const restaurantDetails = '/restaurants/:id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const tracking = '/orders/:id/tracking';
  static String trackingPath(String id) => '/orders/$id/tracking';

  static String restaurantPath(String id) => '/restaurants/$id';
}

/// قاعدة الحماية: ترجع المسار البديل أو null (اعرض المسار المطلوب).
String? authRedirect({required String location, required bool hasAccess}) {
  if (location == AppRoutes.splash) return null;

  final isLogin = location == AppRoutes.login;
  if (!hasAccess && !isLogin) return AppRoutes.login;
  if (hasAccess && isLogin) return AppRoutes.restaurants;
  return null;
}

GoRouter createAppRouter({
  required AuthCubit authCubit,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) => authRedirect(
      location: state.matchedLocation,
      hasAccess: authCubit.state.hasAccess,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
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
}