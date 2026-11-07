import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/data/models/stats_models.dart';
import 'package:flutter_application_1/features/progress/data/datasources/stats_service.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late DateTime _selectedDate = widget.date;

  DateTime get _weekStart => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day - (_selectedDate.weekday - DateTime.monday),
  );

  String get _subtitle =>
      '${_selectedDate.day.toString().padLeft(2, '0')}/'
      '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year} · Dữ liệu mẫu';

  @override
  Widget build(BuildContext context) {
    final stats = StatsService.instance.dayForDate(_selectedDate);
    final activities = StatsService.instance.activitiesForDate(_selectedDate);
    final subjects = activities
        .map(
          (activity) => activity.title == 'Ôn flashcard'
              ? activity.description.split(' · ').first
              : activity.title,
        )
        .toSet()
        .length;

    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsPageHeader(
                title: 'Chi tiết ngày học',
                subtitle: _subtitle,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 12),
              _DaySelector(
                weekStart: _weekStart,
                selectedDate: _selectedDate,
                onSelect: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 12),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatStudyTime(stats.minutes),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              height: 36 / 28,
                              fontWeight: FontWeight.w700,
                              color: AuthColors.navy,
                            ),
                          ),
                        ),
                        if (stats.minutes >= 120)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statsSuccessTint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Đạt mục tiêu 2h',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                height: 18 / 12,
                                color: Color(0xFF1E6B45),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DayMetric(
                            label: 'Hoạt động học',
                            value: '${activities.length} hoạt động',
                          ),
                        ),
                        Expanded(
                          child: _DayMetric(
                            label: 'Môn đã học',
                            value: '$subjects môn học',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Các hoạt động trong ngày',
                      style: AuthTextStyles.label,
                    ),
                    const SizedBox(height: 10),
                    if (activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Chưa có hoạt động học trong ngày.',
                          textAlign: TextAlign.center,
                          style: AuthTextStyles.caption,
                        ),
                      )
                    else
                      for (
                        var index = 0;
                        index < activities.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(height: 10),
                        _ActivityRow(activity: activities[index]),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EBC4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Gợi ý: dành 10 phút ôn lại 3 thẻ chưa nhớ trước buổi học tiếp theo.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 20 / 14,
                    color: Color(0xFF705900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.weekStart,
    required this.selectedDate,
    required this.onSelect,
  });

  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < 7; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _DaySelectorCell(
              date: weekStart.add(Duration(days: index)),
              selected: _sameDate(
                weekStart.add(Duration(days: index)),
                selectedDate,
              ),
              onTap: () => onSelect(weekStart.add(Duration(days: index))),
            ),
          ),
        ],
      ],
    );
  }
}

class _DaySelectorCell extends StatelessWidget {
  const _DaySelectorCell({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AuthColors.navy : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekdayLabel(date),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 18 / 12,
                  color: selected ? const Color(0xFFC8CFDF) : AuthColors.muted,
                ),
              ),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AuthColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayMetric extends StatelessWidget {
  const _DayMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AuthTextStyles.caption),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: AuthColors.navy,
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final StudyActivity activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 46,
          child: Column(
            children: [
              Text(
                activity.time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 18 / 12,
                  color: AuthColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.circle, size: 6, color: Color(0xFFC9A227)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AuthColors.navyTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: AuthColors.navy,
                        ),
                      ),
                    ),
                    Text(
                      '${activity.durationMinutes}p',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 18 / 12,
                        color: AuthColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  activity.description,
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
            ),
          ),
        ),
      ],
    );
  }
}

bool _sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
