import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/schedule_event.dart';

class ReminderService {
  ReminderService._();

  static final instance = ReminderService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> scheduleFor(ScheduleEvent event) async {
    if (kIsWeb) return;
    await initialize();
    await cancelFor(event.id);
    final reminderOffsets = _offsetsFor(event.reminder);
    for (final offset in reminderOffsets) {
      final scheduledAt = event.endsAt.subtract(offset);
      if (!scheduledAt.isAfter(DateTime.now())) continue;
      await _plugin.zonedSchedule(
        id: _notificationId(event.id, offset),
        title: 'V-STUDY: ${event.title}',
        body: 'Sắp đến hạn lúc ${_timeLabel(event.endsAt)}.',
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'vstudy_deadlines',
            'Deadline và lịch học',
            channelDescription: 'Nhắc deadline và lịch học V-STUDY',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelFor(String eventId) async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.cancel(
      id: _notificationId(eventId, const Duration(days: 1)),
    );
    await _plugin.cancel(
      id: _notificationId(eventId, const Duration(hours: 1)),
    );
  }

  List<Duration> _offsetsFor(String reminder) {
    if (reminder.contains('1 ngày') && reminder.contains('1 tiếng')) {
      return const [Duration(days: 1), Duration(hours: 1)];
    }
    if (reminder.contains('1 ngày')) return const [Duration(days: 1)];
    if (reminder.contains('1 tiếng')) return const [Duration(hours: 1)];
    return const [];
  }

  int _notificationId(String eventId, Duration offset) =>
      Object.hash(eventId, offset.inMinutes) & 0x7fffffff;

  String _timeLabel(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
