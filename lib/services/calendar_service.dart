import 'package:flutter/material.dart';

import '../models/calendar_event.dart';

class CalendarService extends ChangeNotifier {
  CalendarService._();

  static final CalendarService instance = CalendarService._();

  final List<CalendarEvent> _events = [
    CalendarEvent(
      id: 'class-calculus-1',
      title: 'Giải Tích 1',
      subject: 'Giải Tích 1',
      type: CalendarEventType.classSession,
      format: CalendarEventFormat.inClass,
      date: DateTime(2026, 10, 15),
      startTime: const TimeOfDay(hour: 7, minute: 30),
      endTime: const TimeOfDay(hour: 9, minute: 30),
      location: 'Phòng K.P206',
      note: '',
      repeat: 'Hằng tuần',
      reminder: 'Trước 1 tiếng',
      checklist: const [
        'Chuẩn bị bài mới',
        'Đọc trước mục 3.1',
        'Ôn kiến thức đã học',
        'Làm báo cáo',
      ],
    ),
    CalendarEvent(
      id: 'class-networking',
      title: 'Lập Trình Mạng',
      subject: 'Lập Trình Mạng',
      type: CalendarEventType.classSession,
      format: CalendarEventFormat.inClass,
      date: DateTime(2026, 10, 15),
      startTime: const TimeOfDay(hour: 13, minute: 0),
      endTime: const TimeOfDay(hour: 16, minute: 30),
      location: 'Phòng V.P306',
      note: 'Mang theo laptop.',
      repeat: 'Hằng tuần',
      reminder: 'Trước 1 tiếng',
      checklist: const ['Kiểm tra bài tập trước giờ học'],
    ),
    CalendarEvent(
      id: 'self-study-linear-algebra',
      title: 'Ôn tập Đại Số Tuyến Tính',
      subject: 'Đại Số Tuyến Tính',
      type: CalendarEventType.selfStudy,
      format: CalendarEventFormat.selfStudy,
      date: DateTime(2026, 10, 15),
      startTime: const TimeOfDay(hour: 19, minute: 0),
      endTime: const TimeOfDay(hour: 21, minute: 30),
      location: '',
      note: '',
      repeat: 'Không lặp lại',
      reminder: 'Không nhắc trước',
      checklist: const [],
    ),
    CalendarEvent(
      id: 'deadline-ui-report',
      title: 'Nộp báo cáo UX/UI',
      subject: 'UX/UI',
      type: CalendarEventType.deadline,
      format: CalendarEventFormat.free,
      date: DateTime(2026, 10, 17),
      startTime: const TimeOfDay(hour: 18, minute: 0),
      endTime: const TimeOfDay(hour: 19, minute: 0),
      location: '',
      note: 'Hoàn thiện phần prototype.',
      repeat: 'Không lặp lại',
      reminder: 'Trước 1 tiếng',
      checklist: const ['Kiểm tra file', 'Nộp bản cuối'],
    ),
    CalendarEvent(
      id: 'deadline-project',
      title: 'Deadline: Đồ án chuyên ngành',
      subject: 'Đồ án chuyên ngành',
      type: CalendarEventType.deadline,
      format: CalendarEventFormat.free,
      date: DateTime(2026, 10, 21),
      startTime: const TimeOfDay(hour: 16, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
      location: '',
      note: 'Nộp báo cáo qua hệ thống.',
      repeat: 'Không lặp lại',
      reminder: 'Trước 1 tiếng',
      checklist: const [],
    ),
  ];

  List<CalendarEvent> get events => List.unmodifiable(_events);

  List<CalendarEvent> eventsForDate(DateTime date) {
    final events =
        _events.where((event) => _sameDate(event.date, date)).toList()
          ..sort((first, second) => first.startsAt.compareTo(second.startsAt));
    return List.unmodifiable(events);
  }

  List<CalendarEvent> eventsInRange(DateTime start, DateTime end) {
    final events =
        _events
            .where(
              (event) =>
                  !event.date.isBefore(
                    DateTime(start.year, start.month, start.day),
                  ) &&
                  !event.date.isAfter(DateTime(end.year, end.month, end.day)),
            )
            .toList()
          ..sort((first, second) => first.startsAt.compareTo(second.startsAt));
    return List.unmodifiable(events);
  }

  CalendarEvent? eventById(String id) {
    for (final event in _events) {
      if (event.id == id) return event;
    }
    return null;
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(CalendarEvent event) {
    final index = _events.indexWhere((candidate) => candidate.id == event.id);
    if (index < 0) return;
    _events[index] = event;
    notifyListeners();
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
    notifyListeners();
  }

  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
