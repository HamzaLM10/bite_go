import 'package:bite_go/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bite_go/features/cart/presentation/pages/cart_page.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// أصناف محلية بأسعار تعطي مجاميع مميّزة (انظر الشرح أعلاه).
const _shawarma = MenuItem(
  id: 'm1',
  restaurantId: 'r1',
  name: 'شاورما دجاج',
  description: 'مع ثوم ومخلل وبطاطا',
  price: 20000.0,
  imageUrl: '',
  category: 'ساندويش',
);

const _lemonade = MenuItem(
  id: 'm3',
  restaurantId: 'r1',
  name: 'عصير ليمون بالنعناع',
  description: 'منعش وطازج',
  price: 10000.0,
  imageUrl: '',
  category: 'مشروبات',
);

/// يبني CartPage فوق Cubit جاهز. يرجع الـ Cubit في حال احتاجه الاختبار.
Widget _buildPage(CartCubit cubit) {
  return BlocProvider.value(
    value: cubit,
    child: const MaterialApp(home: CartPage()),
  );
}

/// سلة فيها: شاورما ×2 (40,000) + عصير ×1 (10,000) = 50,000
CartCubit _filledCart() {
  final cubit = CartCubit()
    ..add(_shawarma)
    ..add(_shawarma)
    ..add(_lemonade);
  return cubit;
}

void main() {
  testWidgets('سلة فارغة: رسالة فقط بدون مجموع', (tester) async {
    final cubit = CartCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildPage(cubit));

    expect(find.text('سلتك فارغة'), findsOneWidget);
    expect(find.text('المجموع'), findsNothing);
  });

  testWidgets('سلة مملوءة: الأسماء والكميات والمجموع', (tester) async {
    final cubit = _filledCart();
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildPage(cubit));

    expect(find.text('شاورما دجاج'), findsOneWidget);
    expect(find.text('عصير ليمون بالنعناع'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // كمية الشاورما
    expect(find.text('1'), findsOneWidget); // كمية العصير
    expect(find.text('40,000 ل.س'), findsOneWidget); // مجموع بطاقة الشاورما
    expect(find.text('50,000 ل.س'), findsOneWidget); // المجموع الكلي
  });

  testWidgets('زر +: ترتفع الكمية ويتغير المجموع', (tester) async {
    final cubit = _filledCart();
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildPage(cubit));
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('60,000 ل.س'), findsOneWidget); // بطاقة الشاورما
    expect(find.text('70,000 ل.س'), findsOneWidget); // المجموع الكلي
  });

  testWidgets('زر -: تنقص الكمية، وعند الصفر يختفي الصنف', (tester) async {
    final cubit = _filledCart();
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildPage(cubit));

    // 2 ← 1
    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pump();
    expect(find.text('شاورما دجاج'), findsOneWidget);
    expect(find.text('30,000 ل.س'), findsOneWidget); // المجموع الكلي

    // 1 ← 0: يُحذف الصنف
    await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
    await tester.pump();
    expect(find.text('شاورما دجاج'), findsNothing);
    expect(find.text('عصير ليمون بالنعناع'), findsOneWidget);
  });

  testWidgets('زر الحذف: يزيل الصنف كاملاً، وآخر صنف يُرجع الحالة الفارغة',
      (tester) async {
    final cubit = _filledCart();
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildPage(cubit));

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    expect(find.text('شاورما دجاج'), findsNothing); // رغم أن كميته كانت 2
    expect(find.text('عصير ليمون بالنعناع'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    expect(find.text('سلتك فارغة'), findsOneWidget);
  });
}