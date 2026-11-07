import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/domain/usecases/stats_usecases.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class GoalsStreakScreen extends StatefulWidget {
  const GoalsStreakScreen({super.key});

  @override
  State<GoalsStreakScreen> createState() => _GoalsStreakScreenState();
}

class _GoalsStreakScreenState extends State<GoalsStreakScreen> {
  StatsService get _stats => StatsService.instance;

  Future<void> _setGoal() async {
    final goalMinutes = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _DailyGoalSheet(initialMinutes: _stats.dailyGoalMinutes),
    );
    if (goalMinutes == null || !mounted) return;
    _stats.setDailyGoalMinutes(goalMinutes);
    setState(() {});
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SuccessPopup(
        message: 'Đặt mục tiêu thành công!',
        autoCloseDuration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProgress =
        (StatsService.todayStudyMinutes / _stats.dailyGoalMinutes).clamp(
          0.0,
          1.0,
        );
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsPageHeader(
                title: 'Mục tiêu và chuỗi học',
                subtitle: 'Duy trì nhịp học mỗi ngày',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Mục tiêu hôm nay',
                            style: AuthTextStyles.label,
                          ),
                        ),
                        Text(
                          '${StatsService.todayStudyMinutes ~/ 60}h ${StatsService.todayStudyMinutes % 60}p',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AuthColors.navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_stats.dailyGoalMinutes ~/ 60}h ${_stats.dailyGoalMinutes % 60}p',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              height: 36 / 28,
                              fontWeight: FontWeight.w700,
                              color: AuthColors.navy,
                            ),
                          ),
                        ),
                        Text(
                          '${(goalProgress * 100).round()}%',
                          style: AuthTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: goalProgress,
                        minHeight: 8,
                        color: AuthColors.navy,
                        backgroundColor: AuthColors.border,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      goalProgress >= 1
                          ? 'Mục tiêu hôm nay đã hoàn thành.'
                          : 'Còn ${_stats.dailyGoalMinutes - StatsService.todayStudyMinutes} phút để hoàn thành mục tiêu.',
                      style: AuthTextStyles.caption,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _setGoal,
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Đặt mục tiêu mới'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AuthColors.navy,
                        side: const BorderSide(color: AuthColors.navy),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StreakMetric(
                      label: 'Chuỗi hiện tại',
                      value: '${StatsService.streakDays} ngày',
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StreakMetric(
                      label: 'Kỷ lục cá nhân',
                      value: '${StatsService.bestStreakDays} ngày',
                      icon: Icons.emoji_events_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tuần này', style: AuthTextStyles.label),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (
                          var index = 0;
                          index < _stats.weekDays.length;
                          index++
                        ) ...[
                          if (index > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _StreakDay(
                              label: weekdayLabel(_stats.weekDays[index].date),
                              completed:
                                  _stats.weekDays[index].minutes >=
                                  _stats.dailyGoalMinutes,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Đạt mục tiêu ${StatsService.goalDaysMetThisWeek} ngày trong tuần này',
                      style: AuthTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const InsightCard(
                title: 'Một chút mỗi ngày cũng tạo nên khác biệt',
                detail: 'Bạn đang xây dựng thói quen học tập bền vững.',
                leading: _StreakIcon(
                  icon: Icons.bolt_outlined,
                  background: Color(0xFFF6EBC4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyGoalSheet extends StatefulWidget {
  const _DailyGoalSheet({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_DailyGoalSheet> createState() => _DailyGoalSheetState();
}

class _DailyGoalSheetState extends State<_DailyGoalSheet> {
  late double _minutes = widget.initialMinutes.toDouble();

  String get _goalLabel {
    final minutes = _minutes.round();
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder phút';
    if (remainder == 0) return '$hours giờ';
    return '$hours giờ $remainder phút';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          22,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Mục tiêu học mỗi ngày', style: AuthTextStyles.label),
            const SizedBox(height: 8),
            Text(
              _goalLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                height: 36 / 28,
                fontWeight: FontWeight.w700,
                color: AuthColors.navy,
              ),
            ),
            Slider(
              value: _minutes,
              min: 30,
              max: 240,
              divisions: 14,
              label: _goalLabel,
              onChanged: (value) => setState(() => _minutes = value),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_minutes.round()),
              style: FilledButton.styleFrom(
                backgroundColor: AuthColors.navy,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Lưu mục tiêu'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakMetric extends StatelessWidget {
  const _StreakMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFC9A227)),
          const SizedBox(height: 8),
          Text(label, style: AuthTextStyles.caption),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: AuthColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  const _StreakDay({required this.label, required this.completed});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: completed ? AuthColors.navy : AuthColors.navyTint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.circle_outlined,
            size: completed ? 16 : 12,
            color: completed ? Colors.white : AuthColors.grayBlue,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AuthColors.muted),
        ),
      ],
    );
  }
}

class _StreakIcon extends StatelessWidget {
  const _StreakIcon({required this.icon, required this.background});

  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF705900)),
    );
  }
}
