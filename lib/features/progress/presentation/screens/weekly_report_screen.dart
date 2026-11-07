import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/data/datasources/stats_service.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  DateTime? _selectedDate = StatsService.weekStart.add(const Duration(days: 5));

  Future<void> _scheduleNextWeek() async {
    await Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed<void>('/calendar/event-form');
  }

  @override
  Widget build(BuildContext context) {
    final focusDays = StatsService.instance.weeklyFocusDays;
    final selectedDay = focusDays.firstWhere(
      (day) => _sameDate(day.date, _selectedDate),
      orElse: () => focusDays.last,
    );
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsPageHeader(
                title: 'Báo cáo tuần',
                subtitle: '12/10 - 18/10/2026',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatStudyTime(
                              StatsService.instance.weeklyFocusTotalMinutes,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              height: 36 / 28,
                              fontWeight: FontWeight.w700,
                              color: AuthColors.navy,
                            ),
                          ),
                        ),
                        const _ReportPill(label: 'Tăng 18%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Thời gian tập trung trong tuần',
                      style: AuthTextStyles.caption,
                    ),
                    const SizedBox(height: 12),
                    StatBarChart(
                      days: focusDays,
                      selectedDate: _selectedDate,
                      onDayTap: (date) => setState(() => _selectedDate = date),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${weekdayLabel(selectedDay.date)} · ${formatStudyTime(selectedDay.minutes)} tập trung',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 18 / 12,
                        color: AuthColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                    child: _ReportMetric(
                      title: 'Phiên tập trung',
                      value: '${StatsService.focusSessionCount}',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _ReportMetric(
                      title: 'Trung bình/phiên',
                      value: '${StatsService.focusAverageMinutes} phút',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InsightCard(
                title: 'Ngày tập trung nhất',
                detail:
                    '${StatsService.focusBestDay} · ${StatsService.focusBestSession}',
                leading: const _ReportIcon(icon: Icons.bolt_outlined),
              ),
              const SizedBox(height: 10),
              const InsightCard(
                title: 'Giữ nhịp học ổn định',
                detail: 'Bạn đã tập trung trong cả 7 ngày của tuần.',
                leading: _ReportIcon(icon: Icons.calendar_today_outlined),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _scheduleNextWeek,
                icon: const Icon(Icons.calendar_month_outlined, size: 19),
                label: const Text('Xếp lịch cho tuần sau'),
                style: FilledButton.styleFrom(
                  backgroundColor: AuthColors.navy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 22 / 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportPill extends StatelessWidget {
  const _ReportPill({required this.label});

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

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AuthTextStyles.caption,
          ),
          const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}

class _ReportIcon extends StatelessWidget {
  const _ReportIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF6EBC4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF705900)),
    );
  }
}

bool _sameDate(DateTime first, DateTime? second) =>
    second != null &&
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
