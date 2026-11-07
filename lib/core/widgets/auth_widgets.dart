import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/auth_theme.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.48, 1],
          colors: [Color(0xFFE8D2AF), Color(0xFFF7F4F0), Color(0xFFCCD7F2)],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: AuthColors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/auth/auth_back.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'HỌC TẬP THÔNG MINH',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 16 / 11,
              fontWeight: FontWeight.w600,
              color: AuthColors.navySecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AuthColors.white,
        border: Border.all(color: AuthColors.border),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1F2A44),
            offset: Offset(0, 8),
            blurRadius: 28,
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.iconAsset,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.fieldStyle,
    this.labelStyle,
    this.labelGap = 4,
    this.labelPadding = EdgeInsets.zero,
    this.fieldHeight = 48,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? iconAsset;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextStyle? fieldStyle;
  final TextStyle? labelStyle;
  final double labelGap;
  final EdgeInsetsGeometry labelPadding;
  final double fieldHeight;
  final Widget? trailing;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: widget.labelPadding,
          child: Text(
            widget.label,
            style: widget.labelStyle ?? AuthTextStyles.label,
          ),
        ),
        SizedBox(height: widget.labelGap),
        Container(
          height: widget.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AuthColors.white,
            border: Border.all(color: AuthColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (widget.iconAsset != null) ...[
                SvgPicture.asset(widget.iconAsset!, width: 20, height: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  obscureText: _isObscured,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  onChanged: widget.onChanged,
                  style:
                      widget.fieldStyle ??
                      const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        color: AuthColors.text,
                      ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 20 / 14,
                      color: AuthColors.muted,
                    ),
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
              if (widget.obscureText)
                IconButton(
                  tooltip: _isObscured ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 40,
                  ),
                  icon: _isObscured
                      ? SvgPicture.asset(
                          'assets/images/auth/auth_eye_off.svg',
                          width: 20,
                          height: 20,
                        )
                      : const Icon(
                          Icons.visibility_outlined,
                          size: 20,
                          color: AuthColors.navy,
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 50,
    this.borderRadius = 16,
    this.showArrow = true,
    this.enabledBackgroundColor,
    this.disabledBackgroundColor,
    this.enabledForegroundColor,
    this.disabledForegroundColor,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final bool showArrow;
  final Color? enabledBackgroundColor;
  final Color? disabledBackgroundColor;
  final Color? enabledForegroundColor;
  final Color? disabledForegroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            enabled
                ? (enabledBackgroundColor ?? AuthColors.navy)
                : (disabledBackgroundColor ?? AuthColors.navyTint),
          ),
          foregroundColor: WidgetStatePropertyAll(
            enabled
                ? (enabledForegroundColor ?? AuthColors.white)
                : (disabledForegroundColor ?? AuthColors.muted),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          textStyle: WidgetStatePropertyAll(textStyle ?? AuthTextStyles.button),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: Text(label)),
            if (showArrow)
              Positioned(
                right: 16,
                child: SvgPicture.asset(
                  'assets/images/auth/auth_arrow_right.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    enabled ? AuthColors.accent : AuthColors.grayBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AuthColors.navy,
          backgroundColor: AuthColors.white,
          side: const BorderSide(color: AuthColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AuthTextStyles.button,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Center(child: Text('Tiếp tục với Google')),
            Positioned(
              left: 20,
              child: SvgPicture.asset(
                'assets/images/auth/auth_google.svg',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AuthColors.navy : AuthColors.white,
                border: Border.all(
                  color: value ? AuthColors.navy : AuthColors.grayBlue,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: value
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: SvgPicture.asset(
                        'assets/images/auth/auth_check.svg',
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tôi đồng ý với Điều khoản và Chính sách bảo mật.',
                style: AuthTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prompt, style: AuthTextStyles.body),
          const SizedBox(width: 24),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AuthColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              textStyle: AuthTextStyles.label,
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
