import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:bite_go/features/restaurants/domain/entities/restaurant.dart';
import 'package:bite_go/features/restaurants/domain/repositories/restaurant_repository.dart';
import 'package:bite_go/features/restaurants/presentation/pages/restaurant_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bite_go/features/cart/presentation/cubit/cart_cubit.dart';

/// repository يفشل دائماً، لاختبار حالة الخطأ.
class _ThrowingRepository implements RestaurantRepository {
  @override
  Future<List<Restaurant>> getRestaurants() async => throw Exception('fail');

  @override
  Future<Restaurant> getRestaurantById(String id) async =>
      throw Exception('fail');

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) async =>
      throw Exception('fail');
}

Widget _buildPage(RestaurantRepository repository, String restaurantId) {
  return RepositoryProvider<RestaurantRepository>.value(
    value: repository,
    child: BlocProvider(
      create: (_) => CartCubit(),
      child: MaterialApp(
        home: RestaurantDetailsPage(restaurantId: restaurantId),
      ),
    ),
  );
}
void main() {
  final fake = FakeRestaurantRepository(delay: Duration.zero);

  testWidgets('يعرض مؤشر التحميل ثم المنيو', (tester) async {
    await tester.pumpWidget(_buildPage(fake, 'r1'));
    await tester.pump(); // أول frame: حالة Loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // ننتظر انتهاء التحميل
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.widgetWithIcon(IconButton, Icons.add), findsWidgets);
  });

  testWidgets('المطعم المفتوح: أزرار الإضافة مفعّلة', (tester) async {
    await tester.pumpWidget(_buildPage(fake, 'r1'));
    await tester.pumpAndSettle();

    final buttons = tester.widgetList<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add),
    );
    expect(buttons.every((b) => b.onPressed != null), isTrue);
    expect(find.textContaining('المطعم مغلق'), findsNothing);
  });

  testWidgets('المطعم المغلق: تنبيه + أزرار معطّلة', (tester) async {
    await tester.pumpWidget(_buildPage(fake, 'r3'));
    await tester.pumpAndSettle();

    expect(find.textContaining('المطعم مغلق'), findsOneWidget);
    final buttons = tester.widgetList<IconButton>(
      find.widgetWithIcon(IconButton, Icons.add),
    );
    expect(buttons, isNotEmpty);
    expect(buttons.every((b) => b.onPressed == null), isTrue);
  });

  testWidgets('عند الفشل: رسالة خطأ وزر إعادة المحاولة', (tester) async {
    await tester.pumpWidget(_buildPage(_ThrowingRepository(), 'r1'));
    await tester.pumpAndSettle();

    expect(find.text('تعذّر تحميل المطعم. حاول مرة أخرى.'), findsOneWidget);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    // ما زال الـ repository يفشل، فيعود الخطأ بعد إعادة المحاولة.
    expect(find.text('تعذّر تحميل المطعم. حاول مرة أخرى.'), findsOneWidget);
  });
  testWidgets('الإضافة تُظهر شريط السلة', (tester) async {
  await tester.pumpWidget(_buildPage(fake, 'r1'));
  await tester.pumpAndSettle();
  expect(find.text('عرض السلة'), findsNothing);

  await tester.tap(find.widgetWithIcon(IconButton, Icons.add).first);
  await tester.pump();

  expect(find.text('عرض السلة'), findsOneWidget);
});
}
