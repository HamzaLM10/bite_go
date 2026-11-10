import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_header.dart';

const _formMaxWidth = 420.0;

// الجدول الزمني للحركة (بالمللي ثانية)، متحكم واحد لكل شيء.
const _headerDelayMs = 150; // تقلص الترويسة من شاشة الـ Splash
const _headerMs = 1000;
const _fieldsDelayMs = 650; // أول عنصر يبدأ والترويسة قاربت الانتهاء
const _fieldStepMs = 220; // الفاصل بين بداية كل عنصر والذي يليه
const _fieldItemMs = 700; // مدة ظهور العنصر الواحد
const _itemCount = 7; // عنوان، وصف، بريد، كلمة مرور، دخول، ضيف، ملاحظة
const _entranceTotalMs =
    _fieldsDelayMs + (_itemCount - 1) * _fieldStepMs + _fieldItemMs;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _entrance;
  late final Animation<double> _headerProgress;
  late final List<Animation<double>> _reveal;
  bool _entranceStarted = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _entranceTotalMs),
    );

    _headerProgress = CurvedAnimation(
      parent: _entrance,
      curve: Interval(
        _headerDelayMs / _entranceTotalMs,
        (_headerDelayMs + _headerMs) / _entranceTotalMs,
        curve: Curves.easeInOutCubic,
      ),
    );

    // كل عنصر يأخذ مقطعاً (Interval) خاصاً به من الزمن الكلي.
    _reveal = List.generate(_itemCount, (i) {
      final startMs = _fieldsDelayMs + i * _fieldStepMs;
      return CurvedAnimation(
        parent: _entrance,
        curve: Interval(
          startMs / _entranceTotalMs,
          (startMs + _fieldItemMs) / _entranceTotalMs,
          curve: Curves.easeOutCubic,
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entranceStarted) return;
    _entranceStarted = true;
    // MediaQuery لا يُقرأ في initState، لذلك نقرّر هنا مرة واحدة.
    // مَن فعّل "تقليل الحركة" يرى الصفحة النهائية مباشرة.
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Widget _item(int index, Widget child) =>
      _Reveal(animation: _reveal[index], child: child);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // لا SafeArea هنا: الترويسة تملأ الشاشة كاملة عند البداية (كالـ Splash)،
    // والمساحة العلوية والسفلية نتولاها بالحشوات.
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(progress: _headerProgress),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg + bottomInset,
                  ),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      final errorMessage = state is AuthUnauthenticated
                          ? state.errorMessage
                          : null;

                      return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _item(
                              0,
                              Text(
                                'مرحباً بك',
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _item(
                              1,
                              Text(
                                'سجّل دخولك لمتابعة طلباتك',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _item(
                              2,
                              TextFormField(
                                controller: _emailController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'أدخل بريدك الإلكتروني'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _item(
                              3,
                              TextFormField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    tooltip: _obscurePassword
                                        ? 'إظهار كلمة المرور'
                                        : 'إخفاء كلمة المرور',
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                    ? 'أدخل كلمة المرور'
                                    : null,
                              ),
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            _item(
                              4,
                              FilledButton(
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: scheme.onPrimary,
                                        ),
                                      )
                                    : const Text('تسجيل الدخول'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _item(
                              5,
                              OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context
                                          .read<AuthCubit>()
                                          .continueAsGuest(),
                                child: const Text('المتابعة كضيف'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _item(
                              6,
                              Text(
                                'نسخة تجريبية: يقبل أي بريد صالح وكلمة مرور من 6 أحرف فأكثر.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// يُظهر [child] بتلاشٍ مع انزلاق خفيف من الأسفل حسب تقدم [animation].
class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}