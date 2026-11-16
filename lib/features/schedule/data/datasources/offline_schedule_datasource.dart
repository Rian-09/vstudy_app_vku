import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/schedule_event.dart';
import '../local/schedule_database.dart';
import 'schedule_datasource.dart';

/// Local-first schedule datasource.
/// Drift is the source used by the UI; queued operations are pushed to
/// Supabase when connectivity and authentication are available.
class OfflineScheduleDataSource implements ScheduleDataSource {
  OfflineScheduleDataSource({required this.database, required this.client});

  final ScheduleDatabase database;
  final SupabaseClient client;

  SupabaseScheduleDataSource get _remote =>
      SupabaseScheduleDataSource(client);

  @override
  Future<List<ScheduleEvent>> getEvents() async {
    final cached = await database.getEvents();
    final localEvents = cached.map(_fromCached).toList(growable: false);
    if (localEvents.isNotEmpty) {
      unawaited(_refreshFromRemote());
      return localEvents;
    }
    try {
      final remoteEvents = await _remote.getEvents().timeout(
        const Duration(seconds: 5),
      );
      for (final event in remoteEvents) {
        await database.upsertEvent(event);
      }
      return remoteEvents;
    } catch (_) {
      return localEvents;
    }
  }

  @override
  Future<ScheduleEvent?> getEventById(String id) async {
    final events = await database.getEvents();
    final cached = events.where((event) => event.id == id).firstOrNull;
    if (cached != null) return _fromCached(cached);
    try {
      final remote = await _remote.getEventById(id);
      if (remote != null) await database.upsertEvent(remote);
      return remote;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addEvent(ScheduleEvent event) async {
    await database.upsertEvent(event);
    await _enqueue(event, 'upsert');
    unawaited(syncPending());
  }

  @override
  Future<void> updateEvent(ScheduleEvent event) async {
    await database.upsertEvent(event);
    await _enqueue(event, 'upsert');
    unawaited(syncPending());
  }

  @override
  Future<void> deleteEvent(String id) async {
    await database.deleteEvent(id);
    await database.enqueue(
      entityId: id,
      operation: 'delete',
      payload: jsonEncode({'id': id}),
      updatedAt: DateTime.now().toUtc(),
    );
    unawaited(syncPending());
  }

  @override
  Future<void> updateStatus(String id, ScheduleEventStatus status) async {
    final event = await getEventById(id);
    if (event == null) return;
    await updateEvent(event.copyWith(status: status));
  }

  Future<void> _enqueue(ScheduleEvent event, String operation) {
    return database.enqueue(
      entityId: event.id,
      operation: operation,
      payload: jsonEncode(_toPayload(event)),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> syncPending() async {
    if (client.auth.currentUser == null) return;
    final now = DateTime.now().toUtc();
    final operations = (await database.pendingOperations())
        .where((operation) =>
            operation.nextRetryAt == null || !operation.nextRetryAt!.isAfter(now))
        .toList(growable: false);
    for (final operation in operations) {
      try {
        if (operation.operation == 'delete') {
          await _remote.deleteEvent(operation.entityId);
        } else {
          await _remote.upsertEvent(_fromPayload(jsonDecode(operation.payload)));
        }
        await database.removeOperation(operation.id);
      } catch (_) {
        await database.markOperationFailed(
          operation.id,
          attempts: operation.attempts,
        );
      }
    }
  }

  Future<void> _refreshFromRemote() async {
    try {
      final remoteEvents = await _remote.getEvents().timeout(
        const Duration(seconds: 5),
      );
      for (final event in remoteEvents) {
        await database.upsertEvent(event);
      }
    } catch (_) {
      // Local data remains available when remote refresh is unavailable.
    }
  }

  ScheduleEvent _fromCached(CachedScheduleEvent row) => ScheduleEvent(
    id: row.id,
    title: row.title,
    subject: row.subject,
    type: ScheduleEventType.values.byName(row.type),
    format: ScheduleEventFormat.values.byName(row.format),
    startsAt: row.startsAt.toLocal(),
    endsAt: row.endsAt.toLocal(),
    location: row.location,
    note: row.note,
    repeat: row.repeatRule,
    reminder: row.reminder,
    checklist: (jsonDecode(row.checklistJson) as List).cast<String>(),
    status: ScheduleEventStatus.values.byName(row.status),
  );

  Map<String, dynamic> _toPayload(ScheduleEvent event) => {
    'id': event.id,
    'title': event.title,
    'subject': event.subject,
    'type': event.type.name,
    'format': event.format.name,
    'starts_at': event.startsAt.toIso8601String(),
    'ends_at': event.endsAt.toIso8601String(),
    'location': event.location,
    'note': event.note,
    'repeat': event.repeat,
    'reminder': event.reminder,
    'checklist': event.checklist,
    'status': event.status.name,
  };

  ScheduleEvent _fromPayload(dynamic raw) {
    final data = Map<String, dynamic>.from(raw as Map);
    return ScheduleEvent(
      id: data['id'] as String,
      title: data['title'] as String,
      subject: data['subject'] as String,
      type: ScheduleEventType.values.byName(data['type'] as String),
      format: ScheduleEventFormat.values.byName(data['format'] as String),
      startsAt: DateTime.parse(data['starts_at'] as String),
      endsAt: DateTime.parse(data['ends_at'] as String),
      location: data['location'] as String,
      note: data['note'] as String,
      repeat: data['repeat'] as String,
      reminder: data['reminder'] as String,
      checklist: (data['checklist'] as List).cast<String>(),
      status: ScheduleEventStatus.values.byName(data['status'] as String),
    );
  }
}
