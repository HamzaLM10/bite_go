import 'package:bite_go/core/router/app_router.dart';
import 'package:bite_go/core/utils/price_formatter.dart';
import 'package:bite_go/features/cart/domain/entities/cart_item.dart';
import 'package:bite_go/features/cart/domain/entities/payment_method.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:bite_go/features/restaurants/domain/entities/restaurant.dart';
import 'package:bite_go/features/tracking/data/repositories/fake_order_repository.dart';
import 'package:bite_go/features/tracking/domain/entities/order.dart';
import 'package:bite_go/features/tracking/domain/repositories/order_repository.dart';
import 'package:bite_go/features/tracking/presentation/pages/order_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// بيانات معرّفة داخل الاختبار كي لا ينكسر عند تغيير الأسعار الوهمية.
final _shawarma = Restaurant(
  id: 'x1',
  name: 'مطعم الشام',
  cuisine: 'شاورما',
  imageUrl: '',
  rating: 4.5,
  deliveryMinutes: 30,
  deliveryFee: 7500,
  isOpen: true,
);

final _pizza = Restaurant(
  id: 'x2',
  name: 'بيتزا الياسمين',
  cuisine: 'بيتزا',
  imageUrl: '',
  rating: 4.2,
  deliveryMinutes: 40,
  deliveryFee: 10000,
  isOpen: true,
);

MenuItem _item(String restaurantId, double price) => MenuItem(
      id: 'm-$restaurantId',
      restaurantId: restaurantId,
      name: 'صنف',
      description: '',
      price: price,
      imageUrl: '',
      category: 'عام',
    );

Future<Order> _place(
  WidgetTester tester,
  FakeOrderRepository repo,
  Restaurant restaurant,
  double price,
) async {
  // placeOrder فيه تأخير (Future.delayed) والوقت وهمي داخل testWidgets.
  final order = await tester.runAsync(
    () => repo.placeOrder(
      restaurant: restaurant,
      items: [CartItem(menuItem: _item(restaurant.id, price), quantity: 1)],
      address: 'المزة',
      paymentMethod: PaymentMethod.cash,
    ),
  );
  return order!;
}

Widget _buildApp(FakeOrderRepository repo) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (context, state) => Scaffold(
          body: Text('tracking ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );

  return RepositoryProvider<OrderRepository>.value(
    value: repo,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('shows an empty message when there are no orders',
      (tester) async {
    final repo = FakeOrderRepository(delay: Duration.zero);

    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد طلبات بعد'), findsOneWidget);
  });

  testWidgets('lists orders newest first with status and total',
      (tester) async {
    final repo = FakeOrderRepository(delay: Duration.zero);
    final first = await _place(tester, repo, _shawarma, 20000);
    final second = await _place(tester, repo, _pizza, 30000);

    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    expect(find.text(first.id), findsOneWidget);
    expect(find.text(second.id), findsOneWidget);
    expect(find.text('تم استلام الطلب'), findsNWidgets(2));
    expect(find.text(formatPrice(first.total)), findsOneWidget);
    expect(find.text(formatPrice(second.total)), findsOneWidget);

    // الأحدث (الثاني) أعلى الشاشة.
    final firstY = tester.getTopLeft(find.text('مطعم الشام')).dy;
    final secondY = tester.getTopLeft(find.text('بيتزا الياسمين')).dy;
    expect(secondY, lessThan(firstY));
  });

  testWidgets('tapping an order opens its tracking page', (tester) async {
    final repo = FakeOrderRepository(delay: Duration.zero);
    final order = await _place(tester, repo, _shawarma, 20000);

    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text(order.id));
    await tester.pumpAndSettle();

    expect(find.text('tracking ${order.id}'), findsOneWidget);
  });
}