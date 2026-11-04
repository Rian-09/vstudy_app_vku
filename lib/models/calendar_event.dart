import 'package:flutter/material.dart';

enum CalendarEventType { classSession, deadline, selfStudy, free }

enum CalendarEventFormat { inClass, selfStudy, online, free }

extension CalendarEventTypeLabel on CalendarEventType {
  String get label => switch (this) {
    CalendarEventType.classSession => 'Môn học',
    CalendarEventType.deadline => 'Deadline',
    CalendarEventType.selfStudy => 'Tự học',
    CalendarEventType.free => 'Tự do',
  };
}

extension CalendarEventFormatLabel on CalendarEventFormat {
  String get label => switch (this) {
    CalendarEventFormat.inClass => 'Trên lớp',
    CalendarEventFormat.selfStudy => 'Tự học',
    CalendarEventFormat.online => 'Trực tuyến',
    CalendarEventFormat.free => 'Tự do',
  };
}

@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.format,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.note,
    required this.repeat,
    required this.reminder,
    required this.checklist,
  });

  final String id;
  final String title;
  final String subject;
  final CalendarEventType type;
  final CalendarEventFormat format;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String note;
  final String repeat;
  final String reminder;
  final List<String> checklist;

  CalendarEvent copyWith({
    String? title,
    String? subject,
    CalendarEventType? type,
    CalendarEventFormat? format,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? note,
    String? repeat,
    String? reminder,
    List<String>? checklist,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      format: format ?? this.format,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      note: note ?? this.note,
      repeat: repeat ?? this.repeat,
      reminder: reminder ?? this.reminder,
      checklist: checklist ?? this.checklist,
    );
  }

  DateTime get startsAt => DateTime(
    date.year,
    date.month,
    date.day,
    startTime.hour,
    startTime.minute,
  );

  DateTime get endsAt =>
      DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

  Duration get duration => endsAt.difference(startsAt);
}

String formatCalendarTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';
