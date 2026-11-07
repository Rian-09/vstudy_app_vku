import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _emailController.addListener(_updateValidity);
    _passwordController.addListener(_updateValidity);
    _updateValidity();
  }

  void _updateValidity() {
    final isValid =
        _emailPattern.hasMatch(_emailController.text.trim()) &&
        _passwordController.text.isNotEmpty;
    if (isValid != _isValid && mounted) {
      setState(() => _isValid = isValid);
    }
  }

  Future<void> _login() async {
    final success = await ref.read(authControllerProvider.notifier).login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed<void, void>('/home');
      return;
    }
    final error = ref.read(authControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error?.toString() ?? 'Không thể đăng nhập.')),
    );
  }

  Future<void> _sendPasswordReset() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã gửi email đặt lại mật khẩu.'
              : error?.toString() ?? 'Không thể gửi email đặt lại mật khẩu.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_updateValidity)
      ..dispose();
    _passwordController
      ..removeListener(_updateValidity)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 29),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AuthHeader(
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth.clamp(0, 402).toDouble();
                    return Center(
                      child: SizedBox(
                        width: width,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Đăng nhập',
                                style: AuthTextStyles.title,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tiếp tục hành trình học tập của bạn.',
                                style: AuthTextStyles.body,
                              ),
                              const SizedBox(height: 12),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      hint: 'Nhập email của bạn',
                                      iconAsset:
                                          'assets/images/auth/auth_mail.svg',
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: _passwordController,
                                      label: 'Mật khẩu',
                                      hint: 'Nhập mật khẩu',
                                      iconAsset:
                                          'assets/images/auth/auth_lock.svg',
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      onChanged: (_) => _updateValidity(),
                                    ),
                                    SizedBox(
                                      height: 44,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _sendPasswordReset,
                                          style: TextButton.styleFrom(
                                            foregroundColor: AuthColors.navy,
                                            textStyle: AuthTextStyles.label,
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Text('Quên mật khẩu?'),
                                        ),
                                      ),
                                    ),
                                    PrimaryButton(
                                      label: 'Đăng nhập',
                                      onPressed: _isValid &&
                                              !ref
                                                  .watch(authControllerProvider)
                                                  .isLoading
                                          ? _login
                                          : null,
                                    ),
                                    const SizedBox(height: 8),
                                    const _OrDivider(),
                                    const SizedBox(height: 8),
                                    GoogleButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đăng nhập Google chưa khả dụng.',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              AuthSwitchPrompt(
                                prompt: 'Chưa có tài khoản?',
                                action: 'Đăng ký',
                                onPressed: () =>
                                    Navigator.of(context)
                                        .pushNamed('/register'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthColors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'hoặc',
            style: AuthTextStyles.caption.copyWith(color: AuthColors.muted),
          ),
        ),
        const Expanded(child: Divider(color: AuthColors.border, height: 1)),
      ],
    );
  }
}
