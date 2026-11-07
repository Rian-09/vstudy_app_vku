import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/domain/usecases/stats_usecases.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class ExamProgressScreen extends StatelessWidget {
  const ExamProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyProgress =
        (StatsService.examWeeklyHours / StatsService.examWeeklyHoursGoal).clamp(
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
                title: 'Tiến độ ôn thi',
                subtitle:
                    'Học kỳ 1 · Còn ${StatsService.examDaysRemaining} ngày',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Hoàn thành kế hoạch',
                            style: AuthTextStyles.label,
                          ),
                        ),
                        Text(
                          '${(StatsService.examOverallProgress * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            height: 32 / 24,
                            fontWeight: FontWeight.w700,
                            color: AuthColors.navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: StatsService.examOverallProgress,
                        minHeight: 8,
                        color: AuthColors.navy,
                        backgroundColor: AuthColors.border,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Các môn thi đang được ôn tập',
                      style: AuthTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Thời gian ôn tập tuần này',
                            style: AuthTextStyles.label,
                          ),
                        ),
                        Text(
                          '${StatsService.examWeeklyHours}h / ${StatsService.examWeeklyHoursGoal}h',
                          style: AuthTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: weeklyProgress,
                        minHeight: 7,
                        color: statsSuccess,
                        backgroundColor: AuthColors.border,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Còn ${(StatsService.examWeeklyHoursGoal - StatsService.examWeeklyHours).toStringAsFixed(1)} giờ để đạt mục tiêu tuần.',
                      style: AuthTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tiến độ theo môn', style: AuthTextStyles.label),
              const SizedBox(height: 12),
              for (
                var index = 0;
                index < StatsService.examSubjects.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: 15),
                ProgressBarRow(
                  label: StatsService.examSubjects[index].title,
                  progress: StatsService.examSubjects[index].progress,
                  color: StatsService.examSubjects[index].progress >= .7
                      ? statsSuccess
                      : AuthColors.navy,
                ),
              ],
              const SizedBox(height: 18),
              const Text('Gợi ý ôn tập', style: AuthTextStyles.label),
              const SizedBox(height: 10),
              for (
                var index = 0;
                index < StatsService.examInsights.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: 10),
                InsightCard(
                  title: StatsService.examInsights[index].title,
                  detail: StatsService.examInsights[index].detail,
                  leading: _ExamInsightIcon(
                    icon: index == 0
                        ? Icons.trending_up
                        : Icons.menu_book_outlined,
                    color: index == 0 ? statsSuccess : AuthColors.navy,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamInsightIcon extends StatelessWidget {
  const _ExamInsightIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
