import '../entities/schedule_event.dart';

abstract interface class ScheduleRepository {
  Future<List<ScheduleEvent>> getEvents();
  Future<ScheduleEvent?> getEventById(String id);
  Future<void> addEvent(ScheduleEvent event);
  Future<void> updateEvent(ScheduleEvent event);
  Future<void> deleteEvent(String id);
  Future<void> updateStatus(String id, ScheduleEventStatus status);
}
