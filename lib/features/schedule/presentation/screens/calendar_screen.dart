import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/features/schedule/data/models/calendar_event.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/ai_planner/data/datasources/mlkit_ocr_datasource.dart';
import 'package:flutter_application_1/features/ai_planner/domain/entities/ocr_schedule_draft.dart';
import 'package:flutter_application_1/features/ai_planner/domain/services/ocr_schedule_parser.dart';
import 'package:flutter_application_1/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:flutter_application_1/features/schedule/presentation/widgets/calendar_widgets.dart';

const _calendarNavy = Color(0xFF1F2A44);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarViewMode _mode = CalendarViewMode.day;
  DateTime _selectedDate = DateTime.now();

  DateTime get _weekStart => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day - (_selectedDate.weekday - 1),
  );

  void _movePeriod(int amount) {
    setState(() {
      _selectedDate = switch (_mode) {
        CalendarViewMode.day => _selectedDate.add(Duration(days: amount)),
        CalendarViewMode.week => _selectedDate.add(Duration(days: amount * 7)),
        CalendarViewMode.month => DateTime(
          _selectedDate.year,
          _selectedDate.month + amount,
          1,
        ),
      };
    });
  }

  String get _periodLabel {
    if (_mode == CalendarViewMode.day) return _formatDate(_selectedDate);
    if (_mode == CalendarViewMode.month) {
      return '${_monthName(_selectedDate.month)} ${_selectedDate.year}';
    }
    final end = _weekStart.add(const Duration(days: 6));
    if (_weekStart.month == end.month) {
      return '${_weekStart.day} - ${end.day} ${_monthName(end.month)} ${end.year}';
    }
    return '${_weekStart.day} ${_monthName(_weekStart.month)} - '
        '${end.day} ${_monthName(end.month)} ${end.year}';
  }

  Future<void> _openAddForm() async {
    await Navigator.of(context).pushNamed<void>('/calendar/event-form');
  }

  Future<void> _openEvent(CalendarEvent event) async {
    await Navigator.of(context)
        .pushNamed<void>('/calendar/event-detail', arguments: event.id);
  }

  Future<void> _scanTimetable() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    try {
      final ocr = MlKitOcrDataSource();
      final text = await ocr.recognizeFile(image.path);
      await ocr.dispose();
      if (!mounted) return;
      final drafts = const OcrScheduleParser().parse(text);
      if (drafts.isEmpty) {
        _showMessage('Không tìm thấy dòng lịch có ngày và giờ rõ ràng.');
        return;
      }
      final shouldSave = await _confirmOcrDrafts(drafts);
      if (shouldSave != true || !mounted) return;
      final controller = ref.read(scheduleControllerProvider.notifier);
      for (var index = 0; index < drafts.length; index++) {
        final draft = drafts[index];
        await controller.add(_toCalendarEvent(draft, index));
      }
      if (mounted) _showMessage('Đã thêm ${drafts.length} lịch từ ảnh.');
    } on UnsupportedError catch (error) {
      if (mounted) _showMessage(error.message ?? 'OCR chưa hỗ trợ thiết bị này.');
    } catch (error) {
      if (mounted) _showMessage('Không thể đọc ảnh: $error');
    }
  }

  Future<bool?> _confirmOcrDrafts(List<OcrScheduleDraft> drafts) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận lịch từ ảnh'),
        content: SizedBox(
          width: 360,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return ListTile(
                dense: true,
                title: Text(draft.title),
                subtitle: Text(
                  '${_formatDateTime(draft.startsAt)} - ${_formatTime(draft.endsAt)}'
                  '${draft.location.isEmpty ? '' : ' · ${draft.location}'}',
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Thêm lịch')),
        ],
      ),
    );
  }

  CalendarEvent _toCalendarEvent(OcrScheduleDraft draft, int index) => CalendarEvent(
    id: 'ocr-${DateTime.now().microsecondsSinceEpoch}-$index',
    title: draft.title,
    subject: draft.subject,
    type: CalendarEventType.classSession,
    format: CalendarEventFormat.inClass,
    date: DateTime(draft.startsAt.year, draft.startsAt.month, draft.startsAt.day),
    startTime: TimeOfDay.fromDateTime(draft.startsAt),
    endTime: TimeOfDay.fromDateTime(draft.endsAt),
    location: draft.location,
    note: draft.note,
    repeat: 'Không lặp lại',
    reminder: 'Không nhắc',
    checklist: const [],
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDateTime(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')} ${_formatTime(date)}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    return AuthBackground(
      child: SafeArea(
        child: scheduleState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Không thể tải lịch: $error',
              textAlign: TextAlign.center,
            ),
          ),
          data: (events) {
            final dayEvents = events.where((event) => _sameDate(event.date, _selectedDate)).toList()
              ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
            final weekEnd = _weekStart.add(const Duration(days: 6));
            final weekEvents = events.where((event) =>
                !_dateOnly(event.date).isBefore(_dateOnly(_weekStart)) &&
                !_dateOnly(event.date).isAfter(_dateOnly(weekEnd))).toList();
            final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
            final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
            final monthEvents = events.where((event) =>
                !_dateOnly(event.date).isBefore(monthStart) &&
                !_dateOnly(event.date).isAfter(monthEnd)).toList();
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Chưa có lịch học hoặc deadline.'),
                    ),
                  _CalendarTop(
                    selectedDate: _selectedDate,
                    onAdd: _openAddForm,
                    onScan: _scanTimetable,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CalendarModeSwitch(
                      mode: _mode,
                      onChanged: (mode) => setState(() => _mode = mode),
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (_mode == CalendarViewMode.day)
                    _WeekDateStrip(
                      weekStart: _weekStart,
                      selectedDate: _selectedDate,
                      events: weekEvents,
                      onSelect: (date) => setState(() => _selectedDate = date),
                    ),
                  if (_mode == CalendarViewMode.day) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 7),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_weekdayName(_selectedDate.weekday)}, ${_selectedDate.day}/${_selectedDate.month} · còn ${dayEvents.where((event) => event.type == CalendarEventType.selfStudy).length} buổi tự học',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Color(0xFF1F2A44),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _movePeriod(-1),
                            tooltip: 'Ngày trước',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                            icon: const Icon(Icons.chevron_left, color: _calendarNavy, size: 20),
                          ),
                          IconButton(
                            onPressed: () => _movePeriod(1),
                            tooltip: 'Ngày sau',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                            icon: const Icon(Icons.chevron_right, color: _calendarNavy, size: 20),
                          ),
                        ],
                      ),
                    ),
                    DayTimeline(events: dayEvents, onEventTap: _openEvent, onAddTap: _openAddForm),
                  ] else if (_mode == CalendarViewMode.week) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 7),
                      child: _PeriodNavigator(label: _periodLabel, onPrevious: () => _movePeriod(-1), onNext: () => _movePeriod(1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: WeekGrid(
                        weekStart: _weekStart,
                        selectedDate: _selectedDate,
                        events: weekEvents,
                        onEventTap: _openEvent,
                        onDaySelected: (date) => setState(() => _selectedDate = date),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 15),
                      child: _PeriodNavigator(label: _periodLabel, onPrevious: () => _movePeriod(-1), onNext: () => _movePeriod(1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MonthGrid(
                        month: _selectedDate,
                        selectedDate: _selectedDate,
                        events: monthEvents,
                        onDaySelected: (date) => setState(() {
                          _selectedDate = date;
                          _mode = CalendarViewMode.day;
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 8),
                      child: _SelectedDayEvents(date: _selectedDate, events: dayEvents, onEventTap: _openEvent),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const _CalendarLegend(),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year && first.month == second.month && first.day == second.day;
}

/*
            final service = CalendarService.instance;
            final dayEvents = service.eventsForDate(_selectedDate);
            final weekEvents = service.eventsInRange(
              _weekStart,
              _weekStart.add(const Duration(days: 6)),
            );
            final monthEvents = service.eventsInRange(
              DateTime(_selectedDate.year, _selectedDate.month, 1),
              DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CalendarTop(
                    selectedDate: _selectedDate,
                    onAdd: _openAddForm,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CalendarModeSwitch(
                      mode: _mode,
                      onChanged: (mode) => setState(() => _mode = mode),
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (_mode == CalendarViewMode.day)
                    _WeekDateStrip(
                      weekStart: _weekStart,
                      selectedDate: _selectedDate,
                      events: weekEvents,
                      onSelect: (date) => setState(() => _selectedDate = date),
                    ),
                  if (_mode == CalendarViewMode.day) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 7),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_weekdayName(_selectedDate.weekday)}, ${_selectedDate.day}/${_selectedDate.month} · còn ${dayEvents.where((event) => event.type == CalendarEventType.selfStudy).length} buổi tự học',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Color(0xFF1F2A44),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _movePeriod(-1),
                            tooltip: 'Ngày trước',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
                            ),
                            icon: const Icon(
                              Icons.chevron_left,
                              color: _calendarNavy,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _movePeriod(1),
                            tooltip: 'Ngày sau',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
                            ),
                            icon: const Icon(
                              Icons.chevron_right,
                              color: _calendarNavy,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DayTimeline(
                      events: dayEvents,
                      onEventTap: _openEvent,
                      onAddTap: _openAddForm,
                    ),
                  ] else if (_mode == CalendarViewMode.week) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 7),
                      child: _PeriodNavigator(
                        label: _periodLabel,
                        onPrevious: () => _movePeriod(-1),
                        onNext: () => _movePeriod(1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: WeekGrid(
                        weekStart: _weekStart,
                        selectedDate: _selectedDate,
                        events: weekEvents,
                        onEventTap: _openEvent,
                        onDaySelected: (date) => setState(() {
                          _selectedDate = date;
                        }),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 15),
                      child: _PeriodNavigator(
                        label: _periodLabel,
                        onPrevious: () => _movePeriod(-1),
                        onNext: () => _movePeriod(1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MonthGrid(
                        month: _selectedDate,
                        selectedDate: _selectedDate,
                        events: monthEvents,
                        onDaySelected: (date) => setState(() {
                          _selectedDate = date;
                          _mode = CalendarViewMode.day;
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 8),
                      child: _SelectedDayEvents(
                        date: _selectedDate,
                        events: dayEvents,
                        onEventTap: _openEvent,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const _CalendarLegend(),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
*/

class _CalendarTop extends StatelessWidget {
  const _CalendarTop({
    required this.selectedDate,
    required this.onAdd,
    required this.onScan,
  });

  final DateTime selectedDate;
  final VoidCallback onAdd;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/calendar/calendar_header.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(21, 12, 21, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_monthName(selectedDate.month)} ${selectedDate.year}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: _calendarNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thời gian biểu',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          height: 25 / 20,
                          fontWeight: FontWeight.w700,
                          color: _calendarNavy,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: onScan,
                          tooltip: 'Quét thời khóa biểu',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _calendarNavy,
                          ),
                          icon: const Icon(Icons.document_scanner_outlined, size: 20),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 40,
                          child: FilledButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Thêm'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _calendarNavy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 13),
                              shape: const StadiumBorder(),
                              textStyle: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                      ),
                  ],
                ),
                const SizedBox(height: 9),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDateStrip extends StatelessWidget {
  const _WeekDateStrip({
    required this.weekStart,
    required this.selectedDate,
    required this.events,
    required this.onSelect,
  });

  final DateTime weekStart;
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Row(
        children: [
          for (var index = 0; index < 7; index++) ...[
            if (index > 0) const SizedBox(width: 5),
            Expanded(
              child: _WeekDateItem(
                label: labels[index],
                date: weekStart.add(Duration(days: index)),
                selected: _isSameDate(
                  weekStart.add(Duration(days: index)),
                  selectedDate,
                ),
                hasEvent: events.any(
                  (event) => _isSameDate(
                    event.date,
                    weekStart.add(Duration(days: index)),
                  ),
                ),
                onTap: () => onSelect(weekStart.add(Duration(days: index))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekDateItem extends StatelessWidget {
  const _WeekDateItem({
    required this.label,
    required this.date,
    required this.selected,
    required this.hasEvent,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool selected;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _calendarNavy : const Color(0xFFD9D9D9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 43,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      height: 13 / 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _calendarNavy,
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      height: 14 / 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _calendarNavy,
                    ),
                  ),
                ],
              ),
              if (hasEvent && !selected)
                const Positioned(
                  bottom: 3,
                  child: CircleAvatar(radius: 1.5, backgroundColor: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodNavigator extends StatelessWidget {
  const _PeriodNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: 'Kỳ trước',
          icon: const Icon(Icons.chevron_left, color: _calendarNavy),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _calendarNavy,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: 'Kỳ sau',
          icon: const Icon(Icons.chevron_right, color: _calendarNavy),
        ),
      ],
    );
  }
}

class _SelectedDayEvents extends StatelessWidget {
  const _SelectedDayEvents({
    required this.date,
    required this.events,
    required this.onEventTap,
  });

  final DateTime date;
  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Thứ ${date.weekday}, ${date.day}/${date.month}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _calendarNavy,
              ),
            ),
            const Spacer(),
            const Text(
              'Chấm đỏ: Ngày có deadline',
              style: TextStyle(fontFamily: 'Inter', fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 9),
        for (var index = 0; index < events.length; index++) ...[
          if (index > 0) const SizedBox(height: 9),
          EventBlock(
            event: events[index],
            onTap: () => onEventTap(events[index]),
          ),
        ],
      ],
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Lịch học trên lớp', Color(0xFFC8CFDF), Color(0xFF1F2A44)),
      ('Deadline còn dưới 2 ngày', Color(0xFFD64545), Color(0xFF780E0E)),
      ('Lịch ôn tập tự học', Color(0xFFF6EBC4), Color(0xFFC9A227)),
      ('Deadline còn trên 2 ngày', Color(0xFF3E9B6A), Color(0xFF005F2D)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 29),
      child: Wrap(
        spacing: 10,
        runSpacing: 7,
        children: [
          for (final item in items)
            SizedBox(
              width: (MediaQuery.sizeOf(context).width - 72) / 2,
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: item.$2,
                      border: Border.all(color: item.$3),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      item.$1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        height: 12 / 9,
                        color: _calendarNavy,
                      ),
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

String _monthName(int month) => const [
  'Tháng 1',
  'Tháng 2',
  'Tháng 3',
  'Tháng 4',
  'Tháng 5',
  'Tháng 6',
  'Tháng 7',
  'Tháng 8',
  'Tháng 9',
  'Tháng 10',
  'Tháng 11',
  'Tháng 12',
][month - 1];

String _formatDate(DateTime date) => '${_monthName(date.month)}, ${date.year}';

String _weekdayName(int weekday) => switch (weekday) {
  1 => 'Thứ hai',
  2 => 'Thứ ba',
  3 => 'Thứ tư',
  4 => 'Thứ năm',
  5 => 'Thứ sáu',
  6 => 'Thứ bảy',
  _ => 'Chủ nhật',
};

bool _isSameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
