import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_application_1/features/progress/data/models/stats_models.dart';
import 'package:flutter_application_1/features/progress/domain/usecases/stats_usecases.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class StudyStatsScreen extends StatefulWidget {
  const StudyStatsScreen({super.key});

  @override
  State<StudyStatsScreen> createState() => _StudyStatsScreenState();
}

class _StudyStatsScreenState extends State<StudyStatsScreen> {
  StatsPeriod _period = StatsPeriod.week;
  final DateTime _selectedWeekDate = DateTime(2026, 10, 17);
  final DateTime _selectedMonthDate = DateTime(2026, 10, 14);

  StatsService get _stats => StatsService.instance;

  void _openDay(DateTime date) {
    Navigator.of(context).pushNamed<void>('/day-detail', arguments: date);
  }

  String get _subtitle => switch (_period) {
    StatsPeriod.week => 'Tuần này · 12/10 đến 18/10',
    StatsPeriod.month => 'Tháng 10, 2026',
    StatsPeriod.semester => 'Học kỳ 1 · 2026–2027',
  };

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsPageHeader(
                title: 'Thống kê học tập',
                subtitle: _subtitle,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              PeriodTabs(
                selected: _period,
                onChanged: (period) => setState(() => _period = period),
              ),
              const SizedBox(height: 16),
              switch (_period) {
                StatsPeriod.week => _buildWeek(),
                StatsPeriod.month => _buildMonth(),
                StatsPeriod.semester => _buildSemester(),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeek() {
    final days = _stats.weekDays;
    final goalProgress =
        (_stats.weekTotalMinutes / StatsService.weeklyGoalMinutes).clamp(
          0.0,
          1.0,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatStudyTime(_stats.weekTotalMinutes),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        height: 36 / 28,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
                  _StatPill(label: 'Tăng 12%'),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Thời lượng học theo ngày',
                style: AuthTextStyles.caption,
              ),
              const SizedBox(height: 8),
              StatBarChart(
                days: days,
                selectedDate: _selectedWeekDate,
                onDayTap: _openDay,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Chuỗi ngày học',
                value: '${StatsService.streakDays} ngày',
                detail: 'Flashcard: đạt 7/7 ngày',
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: _MetricCard(
                label: 'Quiz trung bình',
                value: '${StatsService.averageQuizScore}%',
                detail: 'Tập trung: 18 phiên',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Mục tiêu 15 giờ', style: AuthTextStyles.label),
                  ),
                  Text(
                    '${(goalProgress * 100).round()}%',
                    style: AuthTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: goalProgress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE7E3D8),
                  color: AuthColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Còn 40p · Tập trung tổng 7h 30p\nMục tiêu flashcard: 20 thẻ mỗi ngày',
                style: AuthTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonth() {
    final daysStudied = _stats.studiedMonthDays.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatStudyTime(_stats.monthTotalMinutes),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        height: 36 / 28,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
                  _StatPill(label: 'Học $daysStudied trên 14 ngày'),
                ],
              ),
              const SizedBox(height: 10),
              HeatMapGrid(
                month: StatsService.month,
                days: _stats.monthDays,
                selectedDate: _selectedMonthDate,
                onDayTap: _openDay,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: _MetricCard(
                label: 'Chuỗi ngày học',
                value: '${StatsService.streakDays} ngày',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'Ngày học nhiều nhất',
                value: '10/10 · 4h 05p',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSemester() {
    final progress =
        StatsService.semesterTotalHours / StatsService.semesterGoalHours;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${StatsService.semesterTotalHours}h',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        height: 36 / 28,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
                  const Text('Mục tiêu 160h', style: AuthTextStyles.caption),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE7E3D8),
                  color: AuthColors.navy,
                ),
              ),
              const SizedBox(height: 14),
              StatLineChart(values: StatsService.semesterWeeklyHours),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Mốc nổi bật', style: AuthTextStyles.label),
        const SizedBox(height: 10),
        InsightCard(
          title: StatsService.semesterInsights[0].title,
          detail: StatsService.semesterInsights[0].detail,
          leading: _InsightBadge(
            child: SvgPicture.asset(
              'assets/images/stats/stats_trending_up.svg',
              width: 23,
              height: 23,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const InsightCard(
          title: 'Giải tích 1 chiếm nhiều giờ nhất',
          detail: '46h trong học kỳ · Xem chi tiết',
          leading: _InsightBadge(
            background: AuthColors.navyTint,
            child: Text(
              '1',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AuthColors.navy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: statsSuccessTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          height: 18 / 12,
          color: Color(0xFF1E6B45),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, this.detail});

  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 18 / 12,
              color: AuthColors.muted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: AuthColors.navy,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 18 / 12,
                color: AuthColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightBadge extends StatelessWidget {
  const _InsightBadge({
    required this.child,
    this.background = const Color(0xFFF6EBC4),
  });

  final Widget child;
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
      child: child,
    );
  }
}
