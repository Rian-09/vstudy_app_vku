import '../../domain/entities/schedule_event.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._dataSource);

  final ScheduleDataSource _dataSource;

  @override
  Future<List<ScheduleEvent>> getEvents() => _dataSource.getEvents();

  @override
  Future<ScheduleEvent?> getEventById(String id) => _dataSource.getEventById(id);

  @override
  Future<void> addEvent(ScheduleEvent event) => _dataSource.addEvent(event);

  @override
  Future<void> updateEvent(ScheduleEvent event) => _dataSource.updateEvent(event);

  @override
  Future<void> deleteEvent(String id) => _dataSource.deleteEvent(id);
}
