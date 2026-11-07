import '../entities/schedule_event.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleEventsUseCase {
  const GetScheduleEventsUseCase(this._repository);
  final ScheduleRepository _repository;
  Future<List<ScheduleEvent>> call() => _repository.getEvents();
}

class GetScheduleEventUseCase {
  const GetScheduleEventUseCase(this._repository);
  final ScheduleRepository _repository;
  Future<ScheduleEvent?> call(String id) => _repository.getEventById(id);
}

class AddScheduleEventUseCase {
  const AddScheduleEventUseCase(this._repository);
  final ScheduleRepository _repository;
  Future<void> call(ScheduleEvent event) => _repository.addEvent(event);
}

class UpdateScheduleEventUseCase {
  const UpdateScheduleEventUseCase(this._repository);
  final ScheduleRepository _repository;
  Future<void> call(ScheduleEvent event) => _repository.updateEvent(event);
}

class DeleteScheduleEventUseCase {
  const DeleteScheduleEventUseCase(this._repository);
  final ScheduleRepository _repository;
  Future<void> call(String id) => _repository.deleteEvent(id);
}
