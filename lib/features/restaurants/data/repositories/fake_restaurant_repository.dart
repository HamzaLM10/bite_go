import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';

class FakeRestaurantRepository implements RestaurantRepository {
  FakeRestaurantRepository({this.delay = const Duration(milliseconds: 600)});

  /// تأخير يحاكي الشبكة، ليظهر loading state في الـ UI. الاختبارات تمرّر Duration.zero
  final Duration delay;

  static const _restaurants = [
    Restaurant(
      id: 'r1',
      name: 'مطبخ الشام',
      cuisine: 'شاورما وفطائر',
      imageUrl: 'https://picsum.photos/seed/shami/600/400',
      rating: 4.7,
      deliveryMinutes: 30,
      deliveryFee: 7500.0,
      isOpen: true,
    ),
    Restaurant(
      id: 'r2',
      name: 'برغر ستيشن',
      cuisine: 'برغر ووجبات سريعة',
      imageUrl: 'https://picsum.photos/seed/burger/600/400',
      rating: 4.4,
      deliveryMinutes: 25,
      deliveryFee: 10000.0,
      isOpen: true,
    ),
    Restaurant(
      id: 'r3',
      name: 'بيتزا فورنو',
      cuisine: 'بيتزا وإيطالي',
      imageUrl: 'https://picsum.photos/seed/pizza/600/400',
      rating: 4.5,
      deliveryMinutes: 40,
      deliveryFee: 12500.0,
      isOpen: false,
    ),
    Restaurant(
      id: 'r4',
      name: 'سوشي ياما',
      cuisine: 'سوشي وآسيوي',
      imageUrl: 'https://picsum.photos/seed/sushi/600/400',
      rating: 4.8,
      deliveryMinutes: 45,
      deliveryFee: 15000.0,
      isOpen: true,
    ),
  ];

  static const _menuItems = [
    MenuItem(id: 'm1', restaurantId: 'r1', name: 'شاورما دجاج', description: 'مع ثوم ومخلل وبطاطا', price: 35000.0, imageUrl: 'https://picsum.photos/seed/m1/400/300', category: 'ساندويش'),
    MenuItem(id: 'm2', restaurantId: 'r1', name: 'فطيرة جبنة', description: 'عجين طازج وجبنة مشكلة', price: 6000.0, imageUrl: 'https://picsum.photos/seed/m2/400/300', category: 'فطائر'),
    MenuItem(id: 'm3', restaurantId: 'r1', name: 'عصير ليمون بالنعناع', description: 'منعش وطازج', price: 20000.0, imageUrl: 'https://picsum.photos/seed/m3/400/300', category: 'مشروبات'),
    MenuItem(id: 'm4', restaurantId: 'r2', name: 'برغر كلاسيك', description: 'لحم بقري وجبنة شيدر', price: 50000.0, imageUrl: 'https://picsum.photos/seed/m4/400/300', category: 'برغر'),
    MenuItem(id: 'm5', restaurantId: 'r2', name: 'بطاطا مقلية', description: 'حصة كبيرة مع صوص', price: 15000.0, imageUrl: 'https://picsum.photos/seed/m5/400/300', category: 'جانبية'),
    MenuItem(id: 'm6', restaurantId: 'r2', name: 'ميلك شيك شوكولا', description: 'كريمي وبارد', price: 30000.0, imageUrl: 'https://picsum.photos/seed/m6/400/300', category: 'مشروبات'),
    MenuItem(id: 'm7', restaurantId: 'r3', name: 'بيتزا مارغريتا', description: 'صلصة طماطم وموزاريلا وريحان', price: 45000.0, imageUrl: 'https://picsum.photos/seed/m7/400/300', category: 'بيتزا'),
    MenuItem(id: 'm8', restaurantId: 'r3', name: 'بيتزا خضار', description: 'فطر وفلفل وزيتون', price: 40000.0, imageUrl: 'https://picsum.photos/seed/m8/400/300', category: 'بيتزا'),
    MenuItem(id: 'm9', restaurantId: 'r3', name: 'تيراميسو', description: 'حلوى إيطالية بالقهوة', price: 30000.0, imageUrl: 'https://picsum.photos/seed/m9/400/300', category: 'حلويات'),
    MenuItem(id: 'm10', restaurantId: 'r4', name: 'رول كاليفورنيا', description: '8 قطع مع أفوكادو وكابوريا', price: 30000.0, imageUrl: 'https://picsum.photos/seed/m10/400/300', category: 'رولات'),
    MenuItem(id: 'm11', restaurantId: 'r4', name: 'نيغيري سلمون', description: '4 قطع سلمون طازج', price: 65000.0, imageUrl: 'https://picsum.photos/seed/m11/400/300', category: 'نيغيري'),
    MenuItem(id: 'm12', restaurantId: 'r4', name: 'شوربة ميسو', description: 'تقدَّم ساخنة', price: 45000.0, imageUrl: 'https://picsum.photos/seed/m12/400/300', category: 'شوربات'),
  ];

  @override
  Future<List<Restaurant>> getRestaurants() async {
    await Future<void>.delayed(delay);
    return _restaurants;
  }

  @override
  Future<Restaurant> getRestaurantById(String id) async {
    await Future<void>.delayed(delay);
    return _restaurants.firstWhere(
      (r) => r.id == id,
      orElse: () => throw StateError('Restaurant $id not found'),
    );
  }

  @override
  Future<List<MenuItem>> getMenu(String restaurantId) async {
    await Future<void>.delayed(delay);
    return _menuItems.where((m) => m.restaurantId == restaurantId).toList();
  }
}