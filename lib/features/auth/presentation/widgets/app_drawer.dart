import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

const _avatarRadius = 32.0;

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) {
          final user = auth is AuthAuthenticated ? auth.user : null;

          return Column(
            children: [
              _DrawerHeader(
                title: user?.name ?? 'زائر',
                subtitle: user?.email ?? 'سجّل دخولك للاستفادة من كل المزايا',
                initial: (user == null || user.name.isEmpty)
                    ? null
                    : user.name[0].toUpperCase(),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('طلباتي'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.orders);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('الوضع الداكن'),
                value: isDark,
                onChanged: (value) => context.read<ThemeCubit>().setMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
              const Spacer(),
              const Divider(height: 1),
              SafeArea(
                top: false,
                child: user == null
                    ? ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('تسجيل الدخول'),
                        onTap: () {
                          Navigator.of(context).pop();
                          // للضيف: العودة لشاشة الدخول (الـ redirect يتولى التنقل).
                          context.read<AuthCubit>().logout();
                        },
                      )
                    : ListTile(
                        iconColor: scheme.error,
                        textColor: scheme.error,
                        leading: const Icon(Icons.logout),
                        title: const Text('تسجيل الخروج'),
                        onTap: () => _logout(context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  // نقرأ كل ما نحتاجه قبل الـ await (لا نلمس الـ context بعده).
  final authCubit = context.read<AuthCubit>();
  final cartCubit = context.read<CartCubit>();
  final navigator = Navigator.of(context);

  final confirmed = await _confirmLogout(
    context,
    hasCart: !cartCubit.state.isEmpty,
  );
  if (!confirmed) return;

  navigator.pop(); // يغلق الـ Drawer
  cartCubit.clear(); // لا تنتقل سلة حساب إلى حساب آخر
  await authCubit.logout();
}

Future<bool> _confirmLogout(
  BuildContext context, {
  required bool hasCart,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('تسجيل الخروج'),
      content: Text(
        hasCart
            ? 'هل تريد تسجيل الخروج؟ سيتم تفريغ سلتك الحالية.'
            : 'هل تريد تسجيل الخروج؟',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('تسجيل الخروج'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.title,
    required this.subtitle,
    required this.initial,
  });

  final String title;
  final String subtitle;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final letter = initial;

    return Container(
      width: double.infinity,
      color: AppColors.secondary, // لون هوية: ثابت في الوضعين
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: AppColors.primary,
              child: letter == null
                  ? const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 32,
                    )
                  : Text(
                      letter,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}