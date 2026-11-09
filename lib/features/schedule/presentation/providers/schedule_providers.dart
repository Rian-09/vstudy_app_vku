import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/calendar_service.dart';
import '../../data/datasources/schedule_datasource.dart';
import '../../data/models/calendar_event.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/entities/schedule_event.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/schedule_usecases.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    final dataSource = url.isEmpty || anonKey.isEmpty
        ? LocalScheduleDataSource(CalendarService.instance)
        : SupabaseScheduleDataSource(Supabase.instance.client);
    return ScheduleRepositoryImpl(dataSource);
  },
);

final getScheduleEventsUseCaseProvider = Provider(
  (ref) => GetScheduleEventsUseCase(ref.watch(scheduleRepositoryProvider)),
);
final addScheduleEventUseCaseProvider = Provider(
  (ref) => AddScheduleEventUseCase(ref.watch(scheduleRepositoryProvider)),
);
final updateScheduleEventUseCaseProvider = Provider(
  (ref) => UpdateScheduleEventUseCase(ref.watch(scheduleRepositoryProvider)),
);
final deleteScheduleEventUseCaseProvider = Provider(
  (ref) => DeleteScheduleEventUseCase(ref.watch(scheduleRepositoryProvider)),
);

final scheduleControllerProvider = StateNotifierProvider<ScheduleController,
    AsyncValue<List<CalendarEvent>>>((ref) {
  final controller = ScheduleController(
    getEvents: ref.watch(getScheduleEventsUseCaseProvider),
    addEvent: ref.watch(addScheduleEventUseCaseProvider),
    updateEvent: ref.watch(updateScheduleEventUseCaseProvider),
    deleteEvent: ref.watch(deleteScheduleEventUseCaseProvider),
  );
  controller.load();
  return controller;
});

class ScheduleController extends StateNotifier<AsyncValue<List<CalendarEvent>>> {
  ScheduleController({
    required this._getEvents,
    required this._addEvent,
    required this._updateEvent,
    required this._deleteEvent,
  }) : super(const AsyncLoading());

  final GetScheduleEventsUseCase _getEvents;
  final AddScheduleEventUseCase _addEvent;
  final UpdateScheduleEventUseCase _updateEvent;
  final DeleteScheduleEventUseCase _deleteEvent;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final events = await _getEvents();
      state = AsyncData(events.map((event) => _toModel(event)).toList());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<bool> add(CalendarEvent event) => _mutate(() => _addEvent(_toEntity(event)));
  Future<bool> update(CalendarEvent event) =>
      _mutate(() => _updateEvent(_toEntity(event)));
  Future<bool> delete(String id) => _mutate(() => _deleteEvent(id));

  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      await action();
      final events = await _getEvents();
      state = AsyncData(events.map((event) => _toModel(event)).toList());
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

ScheduleEvent _toEntity(CalendarEvent event) => ScheduleEvent(
  id: event.id,
  title: event.title,
  subject: event.subject,
  type: ScheduleEventType.values.byName(event.type.name),
  format: ScheduleEventFormat.values.byName(event.format.name),
  startsAt: event.startsAt,
  endsAt: event.endsAt,
  location: event.location,
  note: event.note,
  repeat: event.repeat,
  reminder: event.reminder,
  checklist: event.checklist,
);

CalendarEvent _toModel(ScheduleEvent event) => CalendarEvent(
  id: event.id,
  title: event.title,
  subject: event.subject,
  type: CalendarEventType.values.byName(event.type.name),
  format: CalendarEventFormat.values.byName(event.format.name),
  date: DateTime(event.startsAt.year, event.startsAt.month, event.startsAt.day),
  startTime: TimeOfDay.fromDateTime(event.startsAt),
  endTime: TimeOfDay.fromDateTime(event.endsAt),
  location: event.location,
  note: event.note,
  repeat: event.repeat,
  reminder: event.reminder,
  checklist: event.checklist,
);
