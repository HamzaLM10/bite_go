import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/restaurants/data/repositories/fake_restaurant_repository.dart';
import 'features/restaurants/domain/repositories/restaurant_repository.dart';
import 'features/tracking/data/repositories/fake_order_repository.dart';
import 'features/tracking/domain/repositories/order_repository.dart';

void main() => runApp(const BiteGoApp());

class BiteGoApp extends StatelessWidget {
  const BiteGoApp({super.key});

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
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}