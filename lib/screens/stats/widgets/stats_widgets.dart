import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/stats_models.dart';
import '../../../theme/auth_theme.dart';

const statsSuccess = Color(0xFF3E9B6A);
const statsSuccessTint = Color(0xFFEAF5EE);
const statsDanger = Color(0xFFFF3B43);

class StatsPageHeader extends StatelessWidget {
  const StatsPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Quay lại',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 20, height: 32),
            icon: SvgPicture.asset(
              'assets/images/stats/stats_back.svg',
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    height: 26 / 18,
                    fontWeight: FontWeight.w600,
                    color: AuthColors.text,
                  ),
                ),
                Text(
                  subtitle,
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
        ],
      ),
    );
  }
}

class PeriodTabs extends StatelessWidget {
  const PeriodTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StatsPeriod selected;
  final ValueChanged<StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AuthColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final period in StatsPeriod.values)
            Expanded(
              child: Material(
                color: selected == period
                    ? AuthColors.navy
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onChanged(period),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Text(
                      period.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: selected == period
                            ? Colors.white
                            : AuthColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AuthColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.title,
    required this.detail,
    this.leading,
  });

  final String title;
  final String detail;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: AuthColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
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
        ],
      ),
    );
  }
}

class ProgressBarRow extends StatelessWidget {
  const ProgressBarRow({
    super.key,
    required this.label,
    required this.progress,
    this.color = AuthColors.navy,
  });

  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 20 / 14,
              color: AuthColors.text,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: normalizedProgress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE7E3D8),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 38,
          child: Text(
            '${(normalizedProgress * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 18 / 12,
              color: AuthColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class StatBarChart extends StatelessWidget {
  const StatBarChart({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDayTap,
  });

  final List<StudyDayStat> days;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final selectedIndex = days.indexWhere(
          (day) => _sameDate(day.date, selectedDate),
        );
        return Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (days.isEmpty || width <= 0) return;
                final index = (details.localPosition.dx / width * days.length)
                    .floor()
                    .clamp(0, days.length - 1);
                onDayTap(days[index].date);
              },
              child: SizedBox(
                height: 66,
                width: double.infinity,
                child: CustomPaint(
                  painter: _StatBarPainter(
                    days: days,
                    selectedIndex: selectedIndex,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final day in days)
                  Expanded(
                    child: Text(
                      formatChartTime(day.minutes),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 18 / 12,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                for (final day in days)
                  Expanded(
                    child: Text(
                      weekdayLabel(day.date),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 18 / 12,
                        color: AuthColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class HeatMapGrid extends StatelessWidget {
  const HeatMapGrid({
    super.key,
    required this.month,
    required this.days,
    required this.selectedDate,
    required this.onDayTap,
  });

  final DateTime month;
  final List<StudyDayStat> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final firstWeekday = (DateTime(month.year, month.month, 1).weekday + 6) % 7;
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    final itemCount = ((firstWeekday + dayCount + 6) ~/ 7) * 7;
    return Column(
      children: [
        Row(
          children: [
            for (final weekday in weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    weekday,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 18 / 12,
                      color: AuthColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 37,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - firstWeekday + 1;
            if (dayNumber < 1 || dayNumber > dayCount) {
              return const SizedBox.shrink();
            }
            final date = DateTime(month.year, month.month, dayNumber);
            final stat = days.firstWhere(
              (day) => _sameDate(day.date, date),
              orElse: () => StudyDayStat(date: date, minutes: 0),
            );
            final selected = _sameDate(date, selectedDate);
            final isDeadline = dayNumber == 7;
            final hasActivity = stat.minutes > 0;
            final foreground = hasActivity || isDeadline
                ? Colors.white
                : AuthColors.muted;
            return Material(
              color: isDeadline
                  ? statsDanger
                  : hasActivity
                  ? AuthColors.navy
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => onDayTap(date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(color: const Color(0xFFC9A227), width: 2)
                        : null,
                  ),
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 18 / 12,
                      color: foreground,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class StatLineChart extends StatelessWidget {
  const StatLineChart({super.key, required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 135,
          width: double.infinity,
          child: CustomPaint(painter: _StatLinePainter(values: values)),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ChartCaption('Tuần 1'),
            _ChartCaption('Tuần 6'),
            _ChartCaption('Tuần 12'),
          ],
        ),
      ],
    );
  }
}

class _ChartCaption extends StatelessWidget {
  const _ChartCaption(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 18 / 12,
        color: AuthColors.muted,
      ),
    );
  }
}

class _StatBarPainter extends CustomPainter {
  const _StatBarPainter({required this.days, required this.selectedIndex});

  final List<StudyDayStat> days;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final maxMinutes = days.fold<int>(
      1,
      (maximum, day) => math.max(maximum, day.minutes),
    );
    final slotWidth = size.width / days.length;
    final barWidth = slotWidth * .82;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var index = 0; index < days.length; index++) {
      final barHeight = math.max(
        3.0,
        size.height * .88 * days[index].minutes / maxMinutes,
      );
      paint.color = index == selectedIndex
          ? const Color(0xFFC9A227)
          : AuthColors.navy;
      final rect = Rect.fromLTWH(
        slotWidth * index + (slotWidth - barWidth) / 2,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StatBarPainter oldDelegate) =>
      oldDelegate.days != days || oldDelegate.selectedIndex != selectedIndex;
}

class _StatLinePainter extends CustomPainter {
  const _StatLinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const leftInset = 10.0;
    const rightInset = 10.0;
    const topInset = 12.0;
    const bottomInset = 18.0;
    final chartWidth = size.width - leftInset - rightInset;
    final chartHeight = size.height - topInset - bottomInset;
    final maxValue = values.reduce(math.max);
    final gridPaint = Paint()
      ..color = const Color(0xFFE7E3D8)
      ..strokeWidth = 1;
    for (var row = 0; row < 3; row++) {
      final y = topInset + chartHeight * row / 2;
      canvas.drawLine(
        Offset(leftInset, y),
        Offset(size.width - rightInset, y),
        gridPaint,
      );
    }
    final points = <Offset>[];
    for (var index = 0; index < values.length; index++) {
      final x = leftInset + chartWidth * index / math.max(1, values.length - 1);
      final y = topInset + chartHeight * (1 - values[index] / maxValue);
      points.add(Offset(x, y));
    }
    final linePaint = Paint()
      ..color = AuthColors.navy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);
    for (var index = 0; index < points.length; index++) {
      canvas.drawCircle(
        points[index],
        index == points.length - 1 ? 4.5 : 3,
        Paint()
          ..color = index == points.length - 1
              ? const Color(0xFFC9A227)
              : AuthColors.navy,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StatLinePainter oldDelegate) =>
      oldDelegate.values != values;
}

String formatStudyTime(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '${remainder}p';
  if (remainder == 0) return '${hours}h';
  return '${hours}h ${remainder.toString().padLeft(2, '0')}p';
}

String formatChartTime(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '${remainder}p';
  return '${hours}h${remainder.toString().padLeft(2, '0')}';
}

String weekdayLabel(DateTime date) => switch (date.weekday) {
  DateTime.monday => 'T2',
  DateTime.tuesday => 'T3',
  DateTime.wednesday => 'T4',
  DateTime.thursday => 'T5',
  DateTime.friday => 'T6',
  DateTime.saturday => 'T7',
  _ => 'CN',
};

bool _sameDate(DateTime date, DateTime? other) =>
    other != null &&
    date.year == other.year &&
    date.month == other.month &&
    date.day == other.day;
