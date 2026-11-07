import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/auth/domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.onBack,
    required this.onEdit,
    this.showIdentity = true,
  });

  final UserProfile user;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final bool showIdentity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              tooltip: 'Quay lại',
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              icon: SvgPicture.asset(
                'assets/images/profile/profile_back.svg',
                width: 30,
                height: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox.square(
            dimension: 128,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onEdit,
                      customBorder: const CircleBorder(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC9A227),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: user.avatarUrl == null
                              ? Image.asset(
                                  'assets/images/profile/profile_avatar.png',
                                  fit: BoxFit.cover,
                                  semanticLabel: 'Ảnh đại diện',
                                )
                              : Image.network(
                                  user.avatarUrl!,
                                  fit: BoxFit.cover,
                                  semanticLabel: 'Ảnh đại diện',
                                  errorBuilder: (context, error, stackTrace) =>
                                      const ColoredBox(
                                        color: Color(0xFFDDE2EE),
                                        child: Icon(
                                          Icons.person_outline,
                                          color: AuthColors.navy,
                                        ),
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -3,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEdit,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 32,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/profile/profile_edit_badge.svg',
                              width: 30,
                              height: 28,
                            ),
                            SvgPicture.asset(
                              'assets/images/profile/profile_edit_icon.svg',
                              width: 19,
                              height: 19,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showIdentity) ...[
          const SizedBox(height: 10),
          Text(user.fullName, style: _ProfileStyles.name),
          const SizedBox(height: 3),
          Text(
            [
              user.email,
              if (user.className.isNotEmpty) user.className,
            ].join(' · '),
            textAlign: TextAlign.center,
            style: _ProfileStyles.identity,
          ),
        ],
      ],
    );
  }
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  static const _stats = [
    ('92%', 'Đúng deadline'),
    ('14h20p', 'Giờ học tuần này'),
    ('8.4', 'Điểm tb Quiz'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < _stats.length; index++) ...[
              if (index > 0)
                Container(width: 1, height: 39, color: const Color(0x66C9A227)),
              Expanded(
                child: Column(
                  children: [
                    Text(_stats[index].$1, style: _ProfileStyles.statValue),
                    const SizedBox(height: 2),
                    Text(
                      _stats[index].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: _ProfileStyles.statLabel,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SvgPicture.asset(
          'assets/images/profile/stats_divider.svg',
          width: 366,
          height: 1,
        ),
      ],
    );
  }
}

class SubjectChips extends StatelessWidget {
  const SubjectChips({super.key, required this.subjects, required this.onAdd});

  final List<String> subjects;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFF4EFEE),
      const Color(0xFFE7E7EE),
      const Color(0xFFE7E3D8),
      const Color(0xFF979EAC),
      const Color(0xFFC9A227),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: [
        for (var index = 0; index < subjects.length; index++)
          _SubjectChip(
            label: subjects[index],
            color: colors[index % colors.length],
            textColor: index == 4 ? Colors.white : Colors.black,
          ),
        _SubjectChip(
          label: '+ Thêm',
          color: AuthColors.navy,
          textColor: Colors.white,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 79,
          height: 33,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                height: 14 / 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.iconBadgeAsset,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.chevronAsset,
    required this.onTap,
  });

  final String iconBadgeAsset;
  final String iconAsset;
  final String title;
  final String subtitle;
  final String chevronAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 61,
          child: Row(
            children: [
              const SizedBox(width: 17),
              SizedBox.square(
                dimension: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(iconBadgeAsset, width: 50, height: 50),
                    if (iconAsset != iconBadgeAsset)
                      SvgPicture.asset(iconAsset, width: 27, height: 27),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ProfileStyles.featureTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _ProfileStyles.featureSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(chevronAsset, width: 9, height: 16),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.badgeAsset,
    required this.iconAsset,
    required this.title,
    this.value,
    this.onChanged,
    this.onTap,
  });

  final String badgeAsset;
  final String iconAsset;
  final String title;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          const SizedBox(width: 13),
          SizedBox.square(
            dimension: 39,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(badgeAsset, width: 39, height: 39),
                SvgPicture.asset(iconAsset, width: 26, height: 26),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: _ProfileStyles.settingTitle)),
          if (value != null)
            Transform.scale(
              scale: 0.84,
              child: Switch(
                value: value!,
                onChanged: onChanged,
                trackColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? const Color(0xFFFBBC05)
                      : const Color(0xFFD9D9D9);
                }),
                activeThumbColor: Colors.white,
                inactiveThumbColor: Colors.white,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            )
          else
            IconButton(
              onPressed: onTap,
              tooltip: title,
              icon: SvgPicture.asset(
                'assets/images/profile/setting_chevron.svg',
                width: 9,
                height: 16,
              ),
            ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: '',
      readOnly: readOnly,
      onTap: onTap,
      fieldStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 20 / 14,
        color: AuthColors.muted,
      ),
      labelStyle: _ProfileStyles.fieldLabel,
      labelGap: 8,
      labelPadding: const EdgeInsets.only(left: 4),
      trailing: suffixIcon,
    );
  }
}

abstract final class _ProfileStyles {
  static const name = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    height: 25 / 20,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
  static const identity = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    height: 16 / 12,
    color: Color(0xB31F2A44),
  );
  static const statValue = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    height: 25 / 20,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
  static const statLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    height: 13 / 10,
    color: Color(0x991F2A44),
  );
  static const featureTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
  static const featureSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    height: 17 / 13,
    fontWeight: FontWeight.w700,
    color: Color(0x801F2A44),
  );
  static const settingTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
  static const fieldLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w700,
    color: AuthColors.navy,
  );
}
