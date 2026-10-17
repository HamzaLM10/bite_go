import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../cubit/order_history_cubit.dart';
import '../cubit/order_history_state.dart';

/// توفّر الـ Cubit فقط (يُنشأ مع الصفحة ويُغلق معها). الرسم في _OrderHistoryView.
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OrderHistoryCubit(context.read<OrderRepository>())..load(),
      child: const _OrderHistoryView(),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        builder: (context, state) => switch (state) {
          OrderHistoryInitial() || OrderHistoryLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          OrderHistoryError(:final message) => _ErrorView(
            message: message,
            onRetry: () => context.read<OrderHistoryCubit>().load(),
          ),
          OrderHistoryLoaded(:final orders) =>
            orders.isEmpty ? const _EmptyView() : _OrdersList(orders: orders),
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: orders.length,
      separatorBuilder: (_ , _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDelivered = order.status == OrderStatus.delivered;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.trackingPath(order.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.restaurantName,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  Text(order.id, style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _statusLabel(order.status),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDelivered
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(order.createdAt),
                      style: textTheme.bodySmall,
                    ),
                  ),
                  Text(formatPrice(order.total), style: textTheme.titleSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// switch على الـ enum بلا default: أي مرحلة جديدة تجبرنا المترجم على تغطيتها.
String _statusLabel(OrderStatus status) => switch (status) {
  OrderStatus.placed => 'تم استلام الطلب',
  OrderStatus.preparing => 'قيد التحضير',
  OrderStatus.onTheWay => 'في الطريق إليك',
  OrderStatus.delivered => 'تم التسليم',
};

/// تنسيق يدوي مؤقت (يُستبدل بـ intl في مرحلة l10n).
String _formatDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}/${two(d.month)}/${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48),
            SizedBox(height: AppSpacing.md),
            Text('لا توجد طلبات بعد', textAlign: TextAlign.center),
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
