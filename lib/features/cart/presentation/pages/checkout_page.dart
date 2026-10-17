import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../restaurants/domain/entities/restaurant.dart';
import '../../../restaurants/domain/repositories/restaurant_repository.dart';
import '../../domain/entities/payment_method.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../tracking/domain/repositories/order_repository.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // نقرأ مطعم السلة مرة واحدة؛ إن كانت فارغة (refresh مثلاً) لا نجلب شيئاً.
    final restaurantId = context.read<CartCubit>().state.restaurantId;

    if (restaurantId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: const Center(child: Text('سلتك فارغة')),
      );
    }

    return BlocProvider(
      create: (context) => CheckoutCubit(context.read<RestaurantRepository>())
        ..load(restaurantId),
      child: _CheckoutView(restaurantId: restaurantId),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) => switch (state) {
        CheckoutInitial() || CheckoutLoading() => Scaffold(
            appBar: AppBar(title: const Text('إتمام الطلب')),
            body: const Center(child: CircularProgressIndicator()),
          ),
        CheckoutError(:final message) => Scaffold(
            appBar: AppBar(title: const Text('إتمام الطلب')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () =>
                        context.read<CheckoutCubit>().load(restaurantId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        CheckoutLoaded(:final restaurant) =>
          _LoadedView(restaurant: restaurant),
      },
    );
  }
}

class _LoadedView extends StatefulWidget {
  const _LoadedView({required this.restaurant});

  final Restaurant restaurant;

  @override
  State<_LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<_LoadedView> {
  final _addressController = TextEditingController();
  PaymentMethod _payment = PaymentMethod.cash;
  bool _isSubmitting = false; 

  bool get _canConfirm => _addressController.text.trim().isNotEmpty;
  

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    // نقرأ كل ما نحتاجه قبل الـ await، فلا نلمس الـ context بعده.
    final cartCubit = context.read<CartCubit>();
    final orderRepository = context.read<OrderRepository>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final items = cartCubit.state.items;

    setState(() => _isSubmitting = true);
    try {
      final order = await orderRepository.placeOrder(
        restaurant: widget.restaurant,
        items: items,
        address: _addressController.text.trim(),
        paymentMethod: _payment,
      );
      cartCubit.clear();
      router.go(AppRoutes.trackingPath(order.id));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('تعذّر إرسال الطلب. حاول مرة أخرى.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartCubit>().state;
    final fee = widget.restaurant.deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(widget.restaurant.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ..._itemRows(cart, theme),
          const Divider(height: AppSpacing.lg * 2),
          _PriceRow(label: 'المجموع الفرعي', value: formatPrice(cart.subtotal)),
          const SizedBox(height: AppSpacing.sm),
          _PriceRow(label: 'أجرة التوصيل', value: formatPrice(fee)),
          const SizedBox(height: AppSpacing.sm),
          _PriceRow(
            label: 'الإجمالي',
            value: formatPrice(cart.subtotal + fee),
            bold: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('عنوان التوصيل', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _addressController,
            onChanged: (_) => setState(() {}),
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'المدينة، الحي، الشارع، رقم البناء',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('طريقة الدفع', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<PaymentMethod>(
            segments: const [
              ButtonSegment(
                value: PaymentMethod.cash,
                label: Text('نقداً عند الاستلام'),
              ),
              ButtonSegment(
                value: PaymentMethod.card,
                label: Text('بطاقة'),
              ),
            ],
            selected: {_payment},
            onSelectionChanged: (s) => setState(() => _payment = s.first),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(
            onPressed: _canConfirm && !_isSubmitting ? _confirm : null,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('تأكيد الطلب'),
          ),
        ),
      ),
    );
  }

  List<Widget> _itemRows(CartState cart, ThemeData theme) => [
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PriceRow(
              label: '${item.quantity} × ${item.menuItem.name}',
              value: formatPrice(item.total),
            ),
          ),
      ];
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}