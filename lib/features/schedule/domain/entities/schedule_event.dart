enum ScheduleEventType { classSession, deadline, selfStudy, free }

enum ScheduleEventFormat { inClass, selfStudy, online, free }

class ScheduleEvent {
  const ScheduleEvent({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.format,
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.note,
    required this.repeat,
    required this.reminder,
    required this.checklist,
  });

  final String id;
  final String title;
  final String subject;
  final ScheduleEventType type;
  final ScheduleEventFormat format;
  final DateTime startsAt;
  final DateTime endsAt;
  final String location;
  final String note;
  final String repeat;
  final String reminder;
  final List<String> checklist;

  ScheduleEvent copyWith({
    String? title,
    String? subject,
    ScheduleEventType? type,
    ScheduleEventFormat? format,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? note,
    String? repeat,
    String? reminder,
    List<String>? checklist,
  }) => ScheduleEvent(
    id: id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    type: type ?? this.type,
    format: format ?? this.format,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    location: location ?? this.location,
    note: note ?? this.note,
    repeat: repeat ?? this.repeat,
    reminder: reminder ?? this.reminder,
    checklist: checklist ?? this.checklist,
  );
}
