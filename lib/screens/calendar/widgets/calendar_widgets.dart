import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/calendar_event.dart';
import '../../../theme/auth_theme.dart';

const _calendarNavy = Color(0xFF1F2A44);
const _calendarGold = Color(0xFFDFA841);
const _gridHeight = 24 * 28.5;

enum CalendarViewMode { day, week, month }

class CalendarModeSwitch extends StatelessWidget {
  const CalendarModeSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = CalendarViewMode.values;
    const labels = ['Ngày', 'Tuần', 'Tháng'];
    return Container(
      height: 39,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (var index = 0; index < modes.length; index++)
            Expanded(
              child: Material(
                color: mode == modes[index]
                    ? _calendarNavy
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onChanged(modes[index]),
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: mode == modes[index]
                            ? Colors.white
                            : _calendarNavy,
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

class EventBlock extends StatelessWidget {
  const EventBlock({
    super.key,
    required this.event,
    required this.onTap,
    this.compact = false,
  });

  final CalendarEvent event;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = calendarEventColor(event);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(compact ? 6 : 15),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 6 : 15),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 3 : 15,
            vertical: compact ? 2 : 8,
          ),
          child: compact
              ? Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8,
                    height: 10 / 8,
                    fontWeight: FontWeight.w700,
                    color: _calendarNavy,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w700,
                        color: _calendarNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.startTime.format(context)} - ${event.endTime.format(context)}'
                      '${event.location.isEmpty ? '' : ' - ${event.location}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        height: 14 / 11,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onAddTap,
  });

  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEventTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SizedBox(
        height: 215,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 34,
                color: _calendarNavy.withValues(alpha: .45),
              ),
              const SizedBox(height: 8),
              const Text('Chưa có lịch', style: AuthTextStyles.body),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm lịch mới'),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: _gridHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var hour = 0; hour <= 24; hour++)
            Positioned(
              top: hour * 28.5,
              left: 0,
              right: 0,
              height: 1,
              child: Row(
                children: [
                  SizedBox(
                    width: 61,
                    child: Text(
                      hour == 0
                          ? '24:00'
                          : '${hour.toString().padLeft(2, '0')}:00',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _calendarNavy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 1, color: const Color(0xFF9A9A9A)),
                  ),
                ],
              ),
            ),
          for (final event in events)
            Positioned(
              left: 70,
              right: 17,
              top: _timePosition(event.startTime),
              height: math.max(54, event.duration.inMinutes / 60 * 28.5),
              child: EventBlock(event: event, onTap: () => onEventTap(event)),
            ),
        ],
      ),
    );
  }
}

class WeekGrid extends StatelessWidget {
  const WeekGrid({
    super.key,
    required this.weekStart,
    required this.events,
    required this.onEventTap,
  });

  final DateTime weekStart;
  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 44),
            for (var index = 0; index < 7; index++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      _WeekDateCell(
                        label: dayLabels[index],
                        date: weekStart.add(Duration(days: index)),
                        events: events,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: _gridHeight,
          child: Stack(
            children: [
              for (var hour = 0; hour <= 24; hour++)
                Positioned(
                  top: hour * 28.5,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          hour == 0 ? '24' : hour.toString().padLeft(2, '0'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: _calendarNavy,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFF9A9A9A),
                        ),
                      ),
                    ],
                  ),
                ),
              for (var dayIndex = 0; dayIndex < 7; dayIndex++)
                for (final event in _eventsForDay(dayIndex))
                  Positioned(
                    left:
                        42 +
                        (dayIndex *
                            (MediaQuery.sizeOf(context).width - 72) /
                            7),
                    width: (MediaQuery.sizeOf(context).width - 80) / 7,
                    top: _timePosition(event.startTime),
                    height: math.max(42, event.duration.inMinutes / 60 * 28.5),
                    child: EventBlock(
                      event: event,
                      compact: true,
                      onTap: () => onEventTap(event),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  List<CalendarEvent> _eventsForDay(int index) {
    final date = weekStart.add(Duration(days: index));
    return events
        .where(
          (event) =>
              event.date.year == date.year &&
              event.date.month == date.month &&
              event.date.day == date.day,
        )
        .toList();
  }
}

class _WeekDateCell extends StatelessWidget {
  const _WeekDateCell({
    required this.label,
    required this.date,
    required this.events,
  });

  final String label;
  final DateTime date;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final selected = date.day == 15 && date.month == 10 && date.year == 2026;
    return Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _calendarNavy : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : _calendarNavy,
            ),
          ),
          Text(
            '${date.day}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : _calendarNavy,
            ),
          ),
          if (events.any((event) => _sameCalendarDate(event.date, date)))
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 1),
              decoration: const BoxDecoration(
                color: Color(0xFFD64545),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final offset = (firstOfMonth.weekday + 6) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cellCount = ((offset + daysInMonth + 6) ~/ 7) * 7;
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
                      fontWeight: FontWeight.w700,
                      color: _calendarNavy,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cellCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 45,
          ),
          itemBuilder: (context, index) {
            final day = index - offset + 1;
            if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
            final date = DateTime(month.year, month.month, day);
            final isSelected = _sameCalendarDate(date, selectedDate);
            final dayEvents = events
                .where((event) => _sameCalendarDate(event.date, date))
                .toList();
            return InkWell(
              onTap: () => onDaySelected(date),
              customBorder: const CircleBorder(),
              child: SizedBox(
                height: 45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _calendarNavy : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected ? Colors.white : _calendarNavy,
                        ),
                      ),
                    ),
                    if (dayEvents.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final event in dayEvents.take(3))
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: event.type == CalendarEventType.deadline
                                    ? const Color(0xFFD64545)
                                    : _calendarGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class EventTypeChips extends StatelessWidget {
  const EventTypeChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CalendarEventType selected;
  final ValueChanged<CalendarEventType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: [
        for (final type in CalendarEventType.values)
          _ChoiceChip(
            label: type.label,
            selected: selected == type,
            onTap: () => onSelected(type),
          ),
      ],
    );
  }
}

class TimeRangePicker extends StatelessWidget {
  const TimeRangePicker({
    super.key,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeButton(
            time: start,
            onPressed: () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: start,
              );
              if (selected != null) onStartChanged(selected);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: Text(
            '−',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _calendarNavy,
            ),
          ),
        ),
        Expanded(
          child: _TimeButton(
            time: end,
            onPressed: () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: end,
              );
              if (selected != null) onEndChanged(selected);
            },
          ),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.onPressed});

  final TimeOfDay time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: _calendarNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(time.format(context)),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _calendarNavy : const Color(0xFFD9D9D9),
      borderRadius: BorderRadius.circular(15),
      elevation: selected ? 0 : 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 115,
          height: 37,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _calendarNavy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _timePosition(TimeOfDay time) =>
    time.hour * 28.5 + time.minute / 60 * 28.5;

bool _sameCalendarDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

Color calendarEventColor(CalendarEvent event) => switch (event.type) {
  CalendarEventType.classSession => const Color(0xFFC8CFDF),
  CalendarEventType.deadline => const Color(0xFFD64545),
  CalendarEventType.selfStudy => const Color(0xFFF6EBC4),
  CalendarEventType.free => const Color(0xFF3E9B6A),
};
