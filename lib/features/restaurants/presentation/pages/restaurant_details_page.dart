import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/price_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../cubit/restaurant_details_cubit.dart';
import '../cubit/restaurant_details_state.dart';
import '../widgets/menu_item_card.dart';
import '../../../../core/router/app_router.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../domain/entities/menu_item.dart';

import 'package:go_router/go_router.dart';

/// توفّر الـ Cubit فقط. الرسم كله في _RestaurantDetailsView.
class RestaurantDetailsPage extends StatelessWidget {
  const RestaurantDetailsPage({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RestaurantDetailsCubit(context.read<RestaurantRepository>())
            ..load(restaurantId),
      child: _RestaurantDetailsView(restaurantId: restaurantId),
    );
  }
}

class _RestaurantDetailsView extends StatelessWidget {
  const _RestaurantDetailsView({required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantDetailsCubit, RestaurantDetailsState>(
      builder: (context, state) => switch (state) {
        RestaurantDetailsInitial() || RestaurantDetailsLoading() => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator()),
        ),
        RestaurantDetailsError(:final message) => Scaffold(
          appBar: AppBar(),
          body: _ErrorView(
            message: message,
            onRetry: () =>
                context.read<RestaurantDetailsCubit>().load(restaurantId),
          ),
        ),
        RestaurantDetailsLoaded() => _LoadedView(state: state),
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});

  final RestaurantDetailsLoaded state;

  @override
  Widget build(BuildContext context) {
    final restaurant = state.restaurant;
    final categories = state.menuByCategory;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _HeaderAppBar(restaurant: restaurant),
          SliverToBoxAdapter(child: _RestaurantInfo(restaurant: restaurant)),
          for (final entry in categories.entries) ...[
            SliverToBoxAdapter(child: _CategoryTitle(title: entry.key)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList.separated(
                itemCount: entry.value.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => MenuItemCard(
                  item: entry.value[index],
                  // TODO(cart): نربطها بـ CartCubit في مرحلة السلة.
                  onAdd: restaurant.isOpen
                      ? () => _addToCart(context, entry.value[index])
                      : null,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
      bottomNavigationBar: const _CartBar(),
    );
  }
}

class _HeaderAppBar extends StatelessWidget {
  const _HeaderAppBar({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(restaurant.name),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              restaurant.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: const Icon(Icons.restaurant, size: 48),
              ),
            ),
            // تدرّج داكن أسفل الصورة ليبقى الاسم مقروءاً فوقها.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    scheme.scrim.withValues(
                      alpha: restaurant.isOpen ? 0.6 : 0.8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantInfo extends StatelessWidget {
  const _RestaurantInfo({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(restaurant.cuisine, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoChip(
                icon: Icons.star_rounded,
                label: '${restaurant.rating}',
                color: scheme.primary,
              ),
              _InfoChip(
                icon: Icons.schedule,
                label: '${restaurant.deliveryMinutes} د',
              ),
              _InfoChip(
                icon: Icons.delivery_dining,
                label: formatPrice(restaurant.deliveryFee),
              ),
            ],
          ),
          if (!restaurant.isOpen) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                'المطعم مغلق حالياً، يمكنك تصفّح القائمة فقط.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(label),
      ],
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  const _CategoryTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
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

Future<void> _addToCart(BuildContext context, MenuItem item) async {
  final cart = context.read<CartCubit>();
  final result = cart.add(item);

  if (result == AddToCartResult.differentRestaurant) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('بدء سلة جديدة؟'),
        content: const Text(
          'سلتك تحتوي أصنافاً من مطعم آخر. هل تريد تفريغها والبدء من هذا المطعم؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تفريغ والبدء'),
          ),
        ],
      ),
    );
    if (confirmed == true) cart.replaceWith(item);
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FilledButton(
              onPressed: () => context.push(AppRoutes.cart),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${state.totalCount}'),
                  const Text('عرض السلة'),
                  Text(formatPrice(state.subtotal)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
