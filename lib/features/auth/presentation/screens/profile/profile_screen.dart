import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_application_1/features/auth/presentation/widgets/profile_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _darkMode = false;
  bool _deadlineReminders = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.valueOrNull;
    if (user == null) {
      return _AuthStatePage(
        message: authState.error?.toString() ?? 'Bạn chưa đăng nhập.',
        onBack: () => Navigator.of(context).maybePop(),
      );
    }
    final features = <_FeatureData>[
      const _FeatureData(
        badge: 'feature_ai_badge.svg',
        icon: 'feature_ai_badge.svg',
        title: 'Lịch sử chat AI',
        subtitle: '12 cuộc trò chuyện',
        chevron: 'feature_chevron_muted.svg',
      ),
      const _FeatureData(
        badge: 'feature_quiz_badge.svg',
        icon: 'feature_quiz_icon.svg',
        title: 'Kết quả quiz',
        subtitle: '38 bài · điểm TB 8.4',
        chevron: 'feature_chevron_muted.svg',
      ),
      const _FeatureData(
        badge: 'feature_plan_badge.svg',
        icon: 'feature_calendar_icon.svg',
        title: 'Kế hoạch học tập',
        subtitle: 'Gợi ý cho hôm nay',
        chevron: 'feature_chevron_dark.svg',
      ),
      const _FeatureData(
        badge: 'feature_documents_badge.svg',
        icon: 'feature_documents_icon.svg',
        title: 'Tài liệu đã lưu',
        subtitle: '14 tài liệu',
        chevron: 'feature_chevron_muted.svg',
      ),
      const _FeatureData(
        badge: 'feature_progress_badge.svg',
        icon: 'feature_chart_icon.svg',
        title: 'Báo cáo tiến độ',
        subtitle: 'Tuần này +2h so với tuần trước',
        chevron: 'feature_chevron_gold.svg',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(
                  user: user,
                  onBack: () => Navigator.of(context).maybePop(),
                  onEdit: _openEditProfile,
                ),
                const SizedBox(height: 17),
                const StatsRow(),
                const SizedBox(height: 17),
                const Text('Môn học của tôi', style: _ProfileSection.title),
                const SizedBox(height: 12),
                SubjectChips(
                  subjects: user.subjects,
                  onAdd: () => _showMessage('Thêm môn học sẽ sớm khả dụng.'),
                ),
                const SizedBox(height: 24),
                const Text('Chức năng', style: _ProfileSection.title),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EFEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < features.length; index++) ...[
                        if (index > 0)
                          SvgPicture.asset(
                            'assets/images/profile/features_divider.svg',
                            width: 358,
                            height: 1,
                          ),
                        FeatureTile(
                          iconBadgeAsset:
                              'assets/images/profile/${features[index].badge}',
                          iconAsset:
                              'assets/images/profile/${features[index].icon}',
                          title: features[index].title,
                          subtitle: features[index].subtitle,
                          chevronAsset:
                              'assets/images/profile/${features[index].chevron}',
                          onTap: () => _openFeature(features[index].title),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text('Cài đặt', style: _ProfileSection.title),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEAEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      SettingTile(
                        badgeAsset:
                            'assets/images/profile/setting_badge_dark.svg',
                        iconAsset: 'assets/images/profile/setting_dark.svg',
                        title: 'Chế độ tối',
                        value: _darkMode,
                        onChanged: (value) => setState(() => _darkMode = value),
                      ),
                      SvgPicture.asset(
                        'assets/images/profile/settings_divider.svg',
                        width: 356,
                        height: 1,
                      ),
                      SettingTile(
                        badgeAsset:
                            'assets/images/profile/setting_badge_reminder.svg',
                        iconAsset:
                            'assets/images/profile/setting_notification.svg',
                        title: 'Nhắc deadline',
                        value: _deadlineReminders,
                        onChanged: (value) =>
                            setState(() => _deadlineReminders = value),
                      ),
                      SvgPicture.asset(
                        'assets/images/profile/settings_divider.svg',
                        width: 356,
                        height: 1,
                      ),
                      SettingTile(
                        badgeAsset:
                            'assets/images/profile/setting_badge_password.svg',
                        iconAsset: 'assets/images/profile/setting_password.svg',
                        title: 'Đổi mật khẩu',
                        onTap: () =>
                            _showMessage('Đổi mật khẩu sẽ sớm khả dụng.'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 228,
                    height: 59,
                    child: FilledButton(
                      onPressed: _confirmLogout,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFAA1919),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          height: 26 / 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditProfile() async {
    await Navigator.of(context).pushNamed<void>('/edit-profile');
    if (mounted) await ref.read(authControllerProvider.notifier).loadCurrentUser();
  }

  void _openFeature(String title) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => _ProfilePlaceholderPage(title: title),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x8FFFFFFF),
      builder: (dialogContext) => ConfirmDialog(
        title: 'Đăng xuất',
        message: 'Bạn có chắc sẽ đăng xuất chứ?',
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    if (shouldLogout != true || !mounted) return;

    final success = await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    if (!success) {
      _showMessage('Không thể đăng xuất.');
      return;
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil<void>('/login', (route) => false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _AuthStatePage extends StatelessWidget {
  const _AuthStatePage({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(onPressed: onBack, child: const Text('Quay lại')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePlaceholderPage extends StatelessWidget {
  const _ProfilePlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AuthColors.navy),
                ),
              ),
              Expanded(
                child: Center(child: Text(title, style: AuthTextStyles.title)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.badge,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chevron,
  });

  final String badge;
  final String icon;
  final String title;
  final String subtitle;
  final String chevron;
}

abstract final class _ProfileSection {
  static const title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
}
