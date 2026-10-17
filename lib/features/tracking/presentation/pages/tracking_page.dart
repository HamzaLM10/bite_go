import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../cubit/tracking_cubit.dart';
import '../cubit/tracking_state.dart';
import '../widgets/tracking_map.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TrackingCubit(context.read<OrderRepository>())..track(orderId),
      child: _TrackingView(orderId: orderId),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) => switch (state) {
          TrackingInitial() ||
          TrackingLoading() => const Center(child: CircularProgressIndicator()),
          TrackingError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => context.read<TrackingCubit>().track(orderId),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          TrackingLoaded(:final order) => _LoadedView(order: order),
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delivered = order.status == OrderStatus.delivered;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(order.restaurantName, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text('رقم الطلب: ${order.id}'),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  delivered
                      ? 'تم تسليم طلبك'
                      : 'الوصول المتوقع: ${_formatTime(order.estimatedDeliveryAt)}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TrackingMap(status: order.status),
        const SizedBox(height: AppSpacing.lg),
        for (final status in OrderStatus.values)
          _StatusStep(
            status: status,
            current: order.status,
            isLast: status == OrderStatus.values.last,
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'الإجمالي: ${formatPrice(order.total)}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: () => context.go(AppRoutes.restaurants),
          child: const Text('العودة للمطاعم'),
        ),
      ],
    );
  }
}

class _StatusStep extends StatelessWidget {
  const _StatusStep({
    required this.status,
    required this.current,
    required this.isLast,
  });

  final OrderStatus status;
  final OrderStatus current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // المراحل المنتهية: index أصغر من الحالية، أو كل المراحل إذا سُلّم الطلب
    final isDone =
        status.index < current.index || current == OrderStatus.delivered;
    final isActive = status == current && !isDone;
    final reached = isDone || isActive;
    final color = reached
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: reached ? color : Colors.transparent,
              child: Icon(
                isDone ? Icons.check : _icon(status),
                size: 18,
                color: reached ? Colors.white : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: isDone
                    ? color
                    : Theme.of(context).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            _label(status),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

String _label(OrderStatus status) => switch (status) {
  OrderStatus.placed => 'تم استلام الطلب',
  OrderStatus.preparing => 'قيد التحضير',
  OrderStatus.onTheWay => 'في الطريق إليك',
  OrderStatus.delivered => 'تم التسليم',
};

IconData _icon(OrderStatus status) => switch (status) {
  OrderStatus.placed => Icons.receipt_long,
  OrderStatus.preparing => Icons.restaurant,
  OrderStatus.onTheWay => Icons.delivery_dining,
  OrderStatus.delivered => Icons.home,
};

String _formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
