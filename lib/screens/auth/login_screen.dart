import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  void _login() {
    final success = AuthService.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (success) {
      Navigator.of(context).pushReplacementNamed<void, void>('/home');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
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
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Tính năng sẽ sớm khả dụng.',
                                                ),
                                              ),
                                            );
                                          },
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
                                      onPressed: _isValid ? _login : null,
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
