import 'package:flutter/material.dart';

import '../../domain/entities/schedule_event.dart';
import 'calendar_event.dart';

extension CalendarEventMapper on CalendarEvent {
  ScheduleEvent toEntity() => ScheduleEvent(
    id: id,
    title: title,
    subject: subject,
    type: ScheduleEventType.values.firstWhere((item) => item.name == type.name),
    format: ScheduleEventFormat.values.firstWhere(
      (item) => item.name == format.name,
    ),
    startsAt: startsAt,
    endsAt: endsAt,
    location: location,
    note: note,
    repeat: repeat,
    reminder: reminder,
    checklist: checklist,
  );
}

extension ScheduleEventMapper on ScheduleEvent {
  CalendarEvent toModel() => CalendarEvent(
    id: id,
    title: title,
    subject: subject,
    type: CalendarEventType.values.firstWhere((item) => item.name == type.name),
    format: CalendarEventFormat.values.firstWhere(
      (item) => item.name == format.name,
    ),
    date: DateTime(startsAt.year, startsAt.month, startsAt.day),
    startTime: TimeOfDay.fromDateTime(startsAt),
    endTime: TimeOfDay.fromDateTime(endsAt),
    location: location,
    note: note,
    repeat: repeat,
    reminder: reminder,
    checklist: checklist,
  );
}
