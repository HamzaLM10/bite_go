import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/router/app_router.dart';
import 'core/router/stream_listenable.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/fake_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'features/restaurants/domain/repositories/restaurant_repository.dart';
import 'features/tracking/data/repositories/fake_order_repository.dart';
import 'features/tracking/domain/repositories/order_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // يجب تجهيز التخزين قبل إنشاء أي HydratedCubit (أي قبل runApp).
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  runApp(const BiteGoApp());
}

class BiteGoApp extends StatefulWidget {
  const BiteGoApp({super.key});

  @override
  State<BiteGoApp> createState() => _BiteGoAppState();
}

class _BiteGoAppState extends State<BiteGoApp> {
  // تُنشأ مرة واحدة هنا (وليس داخل build) لأن الـ router يعتمد على الـ Cubit.
  late final AuthCubit _authCubit;
  late final StreamListenable _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(FakeAuthRepository());
    _authRefresh = StreamListenable(_authCubit.stream);
    _router = createAppRouter(
      authCubit: _authCubit,
      refreshListenable: _authRefresh,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefresh.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RestaurantRepository>(
          create: (_) => FakeRestaurantRepository(),
        ),
        RepositoryProvider<OrderRepository>(
          create: (_) => FakeOrderRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider(create: (_) => CartCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => FavoritesCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return MaterialApp.router(
              title: 'Bite Go',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}