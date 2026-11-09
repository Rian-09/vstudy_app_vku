import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/schedule_event.dart';
import '../models/schedule_event_mapper.dart';
import 'calendar_service.dart';

abstract interface class ScheduleDataSource {
  Future<List<ScheduleEvent>> getEvents();
  Future<ScheduleEvent?> getEventById(String id);
  Future<void> addEvent(ScheduleEvent event);
  Future<void> updateEvent(ScheduleEvent event);
  Future<void> deleteEvent(String id);
}

class LocalScheduleDataSource implements ScheduleDataSource {
  LocalScheduleDataSource(this._service);

  final CalendarService _service;

  @override
  Future<List<ScheduleEvent>> getEvents() async =>
      _service.events.map((event) => event.toEntity()).toList(growable: false);

  @override
  Future<ScheduleEvent?> getEventById(String id) async =>
      _service.eventById(id)?.toEntity();

  @override
  Future<void> addEvent(ScheduleEvent event) async =>
      _service.addEvent(event.toModel());

  @override
  Future<void> updateEvent(ScheduleEvent event) async =>
      _service.updateEvent(event.toModel());

  @override
  Future<void> deleteEvent(String id) async => _service.deleteEvent(id);
}

class SupabaseScheduleDataSource implements ScheduleDataSource {
  SupabaseScheduleDataSource(this._client);

  final SupabaseClient _client;

  String get _ownerId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Phiên đăng nhập đã hết hạn.');
    }
    return userId;
  }

  @override
  Future<List<ScheduleEvent>> getEvents() async {
    final rows = await _client
        .from('deadlines')
        .select()
        .eq('owner_id', _ownerId)
        .order('starts_at');
    return (rows as List)
        .map((row) => _fromRow(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<ScheduleEvent?> getEventById(String id) async {
    final row = await _client
        .from('deadlines')
        .select()
        .eq('id', id)
        .eq('owner_id', _ownerId)
        .maybeSingle();
    return row == null ? null : _fromRow(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> addEvent(ScheduleEvent event) async {
    await _client.from('deadlines').insert(_toRow(event));
  }

  @override
  Future<void> updateEvent(ScheduleEvent event) async {
    await _client
        .from('deadlines')
        .update(_toRow(event))
        .eq('id', event.id)
        .eq('owner_id', _ownerId);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _client
        .from('deadlines')
        .delete()
        .eq('id', id)
        .eq('owner_id', _ownerId);
  }

  ScheduleEvent _fromRow(Map<String, dynamic> row) {
    final startsAt = DateTime.parse(row['starts_at'] as String).toLocal();
    final endsAt = DateTime.parse(row['ends_at'] as String).toLocal();
    final rawChecklist = row['checklist'];
    final checklist = rawChecklist is List
        ? rawChecklist.map((item) => item.toString()).toList(growable: false)
        : const <String>[];
    return ScheduleEvent(
      id: row['id'] as String,
      title: row['title'] as String,
      subject: row['subject_name'] as String? ?? '',
      type: ScheduleEventType.values.byName(row['event_type'] as String),
      format: ScheduleEventFormat.values.byName(row['event_format'] as String),
      startsAt: startsAt,
      endsAt: endsAt,
      location: row['location'] as String? ?? '',
      note: row['description'] as String? ?? '',
      repeat: row['repeat_rule'] as String? ?? 'Không lặp lại',
      reminder: row['reminder_label'] as String? ?? 'Không nhắc trước',
      checklist: checklist,
    );
  }

  Map<String, dynamic> _toRow(ScheduleEvent event) {
    final dueAt = event.type == ScheduleEventType.deadline
        ? event.endsAt
        : event.startsAt;
    return {
      'owner_id': _ownerId,
      'title': event.title,
      'subject_name': event.subject,
      'description': event.note,
      'due_at': dueAt.toUtc().toIso8601String(),
      'starts_at': event.startsAt.toUtc().toIso8601String(),
      'ends_at': event.endsAt.toUtc().toIso8601String(),
      'event_type': event.type.name,
      'event_format': event.format.name,
      'location': event.location,
      'repeat_rule': event.repeat,
      'reminder_label': event.reminder,
      'checklist': event.checklist,
      'status': 'todo',
      'priority': _priorityFor(dueAt),
    };
  }

  String _priorityFor(DateTime dueAt) {
    final remaining = dueAt.difference(DateTime.now());
    if (remaining <= const Duration(days: 2)) return 'high';
    if (remaining <= const Duration(days: 7)) return 'medium';
    return 'low';
  }
}
