import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/restaurant.dart';
import '../../../../core/widgets/app_image.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Restaurant restaurant;
  final VoidCallback? onTap;
  final bool isFavorite;

  /// null يخفي زر القلب (البطاقة لا تعرف شيئاً عن الـ Cubit).
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppImage(
                    source: restaurant.imageUrl,
                    width: double.infinity,
                    fallbackIcon: Icons.restaurant,
                    fallbackIconSize: 40,
                  ),
                ),
                if (!restaurant.isOpen)
                  Positioned.fill(
                    child: ColoredBox(
                      color: scheme.scrim.withValues(alpha: 0.55),
                      child: Center(
                        child: Text(
                          'مغلق',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: scheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onFavoriteToggle != null)
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    end: AppSpacing.sm,
                    child: IconButton(
                      tooltip: isFavorite
                          ? 'إزالة من المفضلة'
                          : 'إضافة إلى المفضلة',
                      onPressed: onFavoriteToggle,
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.surface.withValues(alpha: 0.85),
                      ),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: scheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(restaurant.cuisine, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 18, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text('${restaurant.rating}'),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 4),
                      Text('${restaurant.deliveryMinutes} د'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
