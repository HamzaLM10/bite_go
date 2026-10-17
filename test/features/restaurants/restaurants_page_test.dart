import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bite_go/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:bite_go/features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'package:bite_go/features/restaurants/domain/entities/restaurant.dart';
import 'package:bite_go/features/restaurants/domain/repositories/restaurant_repository.dart';
import 'package:bite_go/features/restaurants/presentation/pages/restaurants_page.dart';
import 'package:bite_go/features/restaurants/presentation/widgets/restaurant_card.dart';

void main() {
  late FakeRestaurantRepository repo;
  late FavoritesCubit favorites;
  late List<Restaurant> all;

  /// يجهّز شاشة طويلة (ليُبنى كل ما في الـ ListView) ويحمّل الصفحة.
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // الـ Fake فيه تأخير، فنجلب البيانات خارج الوقت الوهمي.
    repo = FakeRestaurantRepository(delay: Duration.zero);
    all = (await tester.runAsync(() => repo.getRestaurants()))!;

    favorites = FavoritesCubit();
    addTearDown(favorites.close);

    await tester.pumpWidget(
      RepositoryProvider<RestaurantRepository>.value(
        value: repo,
        child: BlocProvider<FavoritesCubit>.value(
          value: favorites,
          child: const MaterialApp(home: RestaurantsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  int cardCount() => find.byType(RestaurantCard).evaluate().length;

  /// زر القلب داخل بطاقة مطعم محدد.
  Finder heartOf(Restaurant r, IconData icon) => find.descendant(
        of: find.widgetWithText(RestaurantCard, r.name),
        matching: find.byIcon(icon),
      );

  testWidgets('shows all restaurants after loading', (tester) async {
    await pumpPage(tester);

    expect(cardCount(), all.length);
  });

  testWidgets('search with no match shows the empty message', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pump(const Duration(milliseconds: 500)); // يتخطى الـ debounce

    expect(find.text('لا توجد مطاعم مطابقة لبحثك'), findsOneWidget);
    expect(cardCount(), 0);
  });

  testWidgets('search by name keeps matching restaurants only', (tester) async {
    await pumpPage(tester);
    final target = all.first;

    await tester.enterText(find.byType(TextField), target.name);
    await tester.pump(const Duration(milliseconds: 500));

    final q = target.name.toLowerCase();
    final expected = all
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q))
        .length;

    expect(cardCount(), expected);
    expect(find.widgetWithText(RestaurantCard, target.name), findsOneWidget);
  });

  testWidgets('cuisine chip filters the list', (tester) async {
    await pumpPage(tester);
    final cuisine = all.first.cuisine;

    await tester.tap(find.widgetWithText(ChoiceChip, cuisine));
    await tester.pump();

    expect(cardCount(), all.where((r) => r.cuisine == cuisine).length);
  });

  testWidgets('open-only switch hides closed restaurants', (tester) async {
    await pumpPage(tester);
    final closed = all.firstWhere((r) => !r.isOpen);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(cardCount(), all.where((r) => r.isOpen).length);
    expect(find.widgetWithText(RestaurantCard, closed.name), findsNothing);
  });

  testWidgets('tapping the heart marks the restaurant as favorite',
      (tester) async {
    await pumpPage(tester);
    final target = all.first;

    expect(heartOf(target, Icons.favorite_border), findsOneWidget);

    await tester.tap(heartOf(target, Icons.favorite_border));
    await tester.pump();

    expect(favorites.state.isFavorite(target.id), isTrue);
    expect(heartOf(target, Icons.favorite), findsOneWidget);
    expect(heartOf(target, Icons.favorite_border), findsNothing);
  });

  testWidgets('favorites chip shows favorites only', (tester) async {
    await pumpPage(tester);
    final target = all.first;

    await tester.tap(heartOf(target, Icons.favorite_border));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilterChip, 'المفضلة'));
    await tester.pump();

    expect(cardCount(), 1);
    expect(find.widgetWithText(RestaurantCard, target.name), findsOneWidget);
  });

  testWidgets('favorites chip with no favorites shows the empty message',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'المفضلة'));
    await tester.pump();

    expect(find.text('لا توجد مطاعم مفضلة بعد'), findsOneWidget);
    expect(cardCount(), 0);
  });
}