import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_updateValidity);
    }
  }

  void _updateValidity() {
    final isValid =
        _nameController.text.trim().isNotEmpty &&
        _emailPattern.hasMatch(_emailController.text.trim()) &&
        _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _acceptedTerms;
    if (isValid != _isValid && mounted) {
      setState(() => _isValid = isValid);
    }
  }

  void _setAcceptedTerms(bool value) {
    setState(() => _acceptedTerms = value);
    _updateValidity();
  }

  void _register() {
    final email = _emailController.text.trim();
    final success = AuthService.instance.register(
      name: _nameController.text.trim(),
      email: email,
      password: _passwordController.text,
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email này đã được đăng ký.')),
      );
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Đăng ký thành công')));
    Navigator.of(context).pushNamedAndRemoveUntil<void>(
      '/login',
      (route) => false,
      arguments: email,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller
        ..removeListener(_updateValidity)
        ..dispose();
    }
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
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Tạo tài khoản',
                                style: AuthTextStyles.title,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Bắt đầu xây dựng lịch học của riêng bạn.',
                                style: AuthTextStyles.body,
                              ),
                              const SizedBox(height: 12),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppTextField(
                                      controller: _nameController,
                                      label: 'Họ và tên',
                                      hint: 'Nhập họ và tên',
                                      iconAsset:
                                          'assets/images/auth/auth_user.svg',
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 8),
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
                                      textInputAction: TextInputAction.next,
                                    ),
                                    if (_passwordController.text.length >= 8)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Mật khẩu mạnh.',
                                          style: AuthTextStyles.caption
                                              .copyWith(
                                                color: AuthColors.success,
                                              ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    AppTextField(
                                      controller: _confirmPasswordController,
                                      label: 'Nhập lại mật khẩu',
                                      hint: 'Nhập mật khẩu',
                                      iconAsset:
                                          'assets/images/auth/auth_lock.svg',
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                    ),
                                    const SizedBox(height: 8),
                                    TermsCheckbox(
                                      value: _acceptedTerms,
                                      onChanged: _setAcceptedTerms,
                                    ),
                                    const SizedBox(height: 8),
                                    PrimaryButton(
                                      label: 'Tạo tài khoản',
                                      onPressed: _isValid ? _register : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              AuthSwitchPrompt(
                                prompt: 'Đã có tài khoản?',
                                action: 'Đăng nhập',
                                onPressed: () =>
                                    Navigator.of(context)
                                        .pushReplacementNamed('/login'),
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
