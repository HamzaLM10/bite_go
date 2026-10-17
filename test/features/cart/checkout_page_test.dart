import 'package:bite_go/core/router/app_router.dart';
import 'package:bite_go/core/utils/price_formatter.dart';
import 'package:bite_go/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bite_go/features/cart/presentation/pages/checkout_page.dart';
import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:bite_go/features/restaurants/domain/repositories/restaurant_repository.dart';
import 'package:bite_go/features/tracking/data/repositories/fake_order_repository.dart';
import 'package:bite_go/features/tracking/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _burger = MenuItem(
  id: 't1',
  restaurantId: 'r1',
  name: 'برغر',
  description: '',
  price: 12000,
  imageUrl: '',
  category: 'وجبات',
);

const _fries = MenuItem(
  id: 't2',
  restaurantId: 'r1',
  name: 'بطاطا',
  description: '',
  price: 8000,
  imageUrl: '',
  category: 'جانبية',
);

Widget _buildPage(CartCubit cartCubit) {
  final router = GoRouter(
    initialLocation: '/checkout',
    routes: [
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (context, state) =>
            Scaffold(body: Text('tracking:${state.pathParameters['id']}')),
      ),
    ],
  );

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<RestaurantRepository>.value(
        value: FakeRestaurantRepository(delay: Duration.zero),
      ),
      RepositoryProvider<OrderRepository>.value(
        value: FakeOrderRepository(
          delay: Duration.zero,
          stepDelay: Duration.zero,
        ),
      ),
    ],
    child: BlocProvider.value(
      value: cartCubit,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

Finder get _confirmButton => find.widgetWithText(FilledButton, 'تأكيد الطلب');

void main() {
  late CartCubit cartCubit;

  setUp(() {
    cartCubit = CartCubit();
  });

  tearDown(() => cartCubit.close());

  testWidgets('shows empty message when the cart is empty', (tester) async {
    await tester.pumpWidget(_buildPage(cartCubit));
    await tester.pumpAndSettle();

    expect(find.text('سلتك فارغة'), findsOneWidget);
  });

  testWidgets('confirm button is disabled until an address is entered', (
    tester,
  ) async {
    cartCubit.add(_burger);
    await tester.pumpWidget(_buildPage(cartCubit));
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(_confirmButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'دمشق - المزة');
    await tester.pump();

    expect(tester.widget<FilledButton>(_confirmButton).onPressed, isNotNull);
  });

  testWidgets('shows subtotal, delivery fee and total', (tester) async {
    cartCubit.add(_burger);
    cartCubit.add(_fries);
    final restaurant = (await tester.runAsync(
      () =>
          FakeRestaurantRepository(delay: Duration.zero)
              .getRestaurantById('r1'),
    ))!;
    await tester.pumpWidget(_buildPage(cartCubit));
    await tester.pumpAndSettle();

    expect(find.text(formatPrice(20000)), findsOneWidget);
    expect(find.text(formatPrice(restaurant.deliveryFee)), findsOneWidget);
    expect(
      find.text(formatPrice(20000 + restaurant.deliveryFee)),
      findsOneWidget,
    );
  });

  testWidgets('confirming the order opens tracking and clears the cart', (
    tester,
  ) async {
    cartCubit.add(_burger);
    await tester.pumpWidget(_buildPage(cartCubit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'دمشق - المزة');
    await tester.pump();
    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();

    expect(find.text('tracking:BG-1001'), findsOneWidget);
    expect(cartCubit.state.isEmpty, isTrue);
  });
}
