import '../../domain/entities/schedule_event.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/calendar_service.dart';
import '../models/schedule_event_mapper.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._dataSource);

  final CalendarService _dataSource;

  @override
  Future<List<ScheduleEvent>> getEvents() async =>
      _dataSource.events.map((event) => event.toEntity()).toList(growable: false);

  @override
  Future<ScheduleEvent?> getEventById(String id) async =>
      _dataSource.eventById(id)?.toEntity();

  @override
  Future<void> addEvent(ScheduleEvent event) async =>
      _dataSource.addEvent(event.toModel());

  @override
  Future<void> updateEvent(ScheduleEvent event) async =>
      _dataSource.updateEvent(event.toModel());

  @override
  Future<void> deleteEvent(String id) async => _dataSource.deleteEvent(id);
}
