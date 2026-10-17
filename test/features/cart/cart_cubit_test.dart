import 'package:bite_go/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bite_go/features/restaurants/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

MenuItem _item(String id, {String restaurantId = 'r1', double price = 10}) =>
    MenuItem(
      id: id,
      restaurantId: restaurantId,
      name: 'Item $id',
      description: 'desc',
      price: price,
      imageUrl: 'x',
      category: 'c',
    );

void main() {
  late CartCubit cubit;

  setUp(() => cubit = CartCubit());
  tearDown(() => cubit.close());

  test('تبدأ فارغة', () {
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.restaurantId, isNull);
    expect(cubit.state.subtotal, 0);
  });

  test('إضافة نفس الصنف مرتين تزيد الكمية ولا تكرر السطر', () {
    cubit.add(_item('a', price: 5));
    cubit.add(_item('a', price: 5));

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.quantity, 2);
    expect(cubit.state.totalCount, 2);
    expect(cubit.state.subtotal, 10);
  });

  test('صنف من مطعم آخر يُرفض وتبقى السلة كما هي', () {
    cubit.add(_item('a', restaurantId: 'r1'));
    final result = cubit.add(_item('b', restaurantId: 'r2'));

    expect(result, AddToCartResult.differentRestaurant);
    expect(cubit.state.restaurantId, 'r1');
    expect(cubit.state.items.length, 1);
  });

  test('replaceWith تفرغ السلة وتبدأ بالصنف الجديد', () {
    cubit.add(_item('a', restaurantId: 'r1'));
    cubit.replaceWith(_item('b', restaurantId: 'r2'));

    expect(cubit.state.restaurantId, 'r2');
    expect(cubit.state.items.single.menuItem.id, 'b');
  });

  test('decrement يُنقص الكمية، وعند الصفر يحذف السطر ويصفّر المطعم', () {
    cubit.add(_item('a'));
    cubit.add(_item('a'));

    cubit.decrement('a');
    expect(cubit.state.items.single.quantity, 1);

    cubit.decrement('a');
    expect(cubit.state.isEmpty, isTrue);
    expect(cubit.state.restaurantId, isNull);
  });

  test('remove يحذف السطر كاملاً، و clear تفرغ السلة', () {
    cubit.add(_item('a'));
    cubit.add(_item('b'));

    cubit.remove('a');
    expect(cubit.state.items.single.menuItem.id, 'b');

    cubit.clear();
    expect(cubit.state.isEmpty, isTrue);
  });
}