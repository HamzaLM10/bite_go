import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../favorites/presentation/cubit/favorites_state.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../bloc/restaurants_bloc.dart';
import '../widgets/restaurant_card.dart';

/// توفّر الـ Bloc فقط. الرسم كله في _RestaurantsView.
class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RestaurantsBloc(context.read<RestaurantRepository>())
            ..add(const RestaurantsStarted()),
      child: const _RestaurantsView(),
    );
  }
}

class _RestaurantsView extends StatelessWidget {
  const _RestaurantsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bite Go'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'طلباتي',
            onPressed: () => context.push(AppRoutes.orders),
          ),
        ],
      ),
      body: BlocBuilder<RestaurantsBloc, RestaurantsState>(
        builder: (context, state) => switch (state) {
          RestaurantsInitial() || RestaurantsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          RestaurantsError(:final message) => _ErrorView(
            message: message,
            onRetry: () =>
                context.read<RestaurantsBloc>().add(const RestaurantsStarted()),
          ),
          RestaurantsLoaded() => const _LoadedView(),
        },
      ),
    );
  }
}

/// الشريط العلوي (بحث + فلاتر) ثابت، والقائمة تحته تتغير مع الحالة.
/// يملك حالة واجهة محلية واحدة: "المفضلة فقط".
class _LoadedView extends StatefulWidget {
  const _LoadedView();

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SearchField(),
        _FiltersBar(
          favoritesOnly: _favoritesOnly,
          onFavoritesChanged: (value) =>
              setState(() => _favoritesOnly = value),
        ),
        Expanded(
          child: BlocBuilder<RestaurantsBloc, RestaurantsState>(
            builder: (context, state) {
              if (state is! RestaurantsLoaded) return const SizedBox.shrink();

              return BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, favorites) {
                  final visible = _favoritesOnly
                      ? state.visibleRestaurants
                            .where((r) => favorites.isFavorite(r.id))
                            .toList()
                      : state.visibleRestaurants;

                  if (visible.isEmpty) {
                    return _favoritesOnly && favorites.ids.isEmpty
                        ? const _EmptyResults(
                            icon: Icons.favorite_border,
                            message: 'لا توجد مطاعم مفضلة بعد',
                          )
                        : const _EmptyResults(
                            icon: Icons.search_off,
                            message: 'لا توجد مطاعم مطابقة لبحثك',
                          );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final restaurant = visible[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        isFavorite: favorites.isFavorite(restaurant.id),
                        onFavoriteToggle: () => context
                            .read<FavoritesCubit>()
                            .toggle(restaurant.id),
                        onTap: () => context.push(
                          AppRoutes.restaurantPath(restaurant.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'ابحث عن مطعم أو مطبخ',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) =>
            context.read<RestaurantsBloc>().add(SearchQueryChanged(value)),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.favoritesOnly,
    required this.onFavoritesChanged,
  });

  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantsBloc, RestaurantsState>(
      builder: (context, state) {
        if (state is! RestaurantsLoaded) return const SizedBox.shrink();
        final bloc = context.read<RestaurantsBloc>();

        return Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  // FilterChip (مفتاح مستقل) وليس ChoiceChip (اختيار واحد من مجموعة).
                  FilterChip(
                    avatar: const Icon(Icons.favorite, size: 18),
                    label: const Text('المفضلة'),
                    selected: favoritesOnly,
                    onSelected: onFavoritesChanged,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: state.cuisine == null,
                    onSelected: (_) =>
                        bloc.add(const CuisineFilterChanged(null)),
                  ),
                  for (final cuisine in state.cuisines) ...[
                    const SizedBox(width: AppSpacing.sm),
                    ChoiceChip(
                      label: Text(cuisine),
                      selected: state.cuisine == cuisine,
                      onSelected: (_) =>
                          bloc.add(CuisineFilterChanged(cuisine)),
                    ),
                  ],
                ],
              ),
            ),
            SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              title: const Text('المفتوح حالياً فقط'),
              value: state.openOnly,
              onChanged: (_) => bloc.add(const OpenOnlyToggled()),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}