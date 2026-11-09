import '../entities/schedule_event.dart';

class ScheduleEventFilter {
  const ScheduleEventFilter({this.subject, this.status, this.from, this.to});

  final String? subject;
  final ScheduleEventStatus? status;
  final DateTime? from;
  final DateTime? to;
}

class FilterScheduleEventsUseCase {
  const FilterScheduleEventsUseCase();

  List<ScheduleEvent> call(
    Iterable<ScheduleEvent> events,
    ScheduleEventFilter filter,
  ) {
    final from = filter.from == null ? null : _dateOnly(filter.from!);
    final to = filter.to == null ? null : _dateOnly(filter.to!);
    final result = events.where((event) {
      final eventDate = _dateOnly(event.startsAt);
      return (filter.subject == null ||
              filter.subject!.isEmpty ||
              event.subject == filter.subject) &&
          (filter.status == null || event.status == filter.status) &&
          (from == null || !eventDate.isBefore(from)) &&
          (to == null || !eventDate.isAfter(to));
    }).toList();
    result.sort((first, second) {
      final priority = _priorityRank(first).compareTo(_priorityRank(second));
      return priority == 0
          ? first.startsAt.compareTo(second.startsAt)
          : priority;
    });
    return result;
  }

  static int _priorityRank(ScheduleEvent event) {
    if (event.status == ScheduleEventStatus.done) return 3;
    final remaining = event.endsAt.difference(DateTime.now());
    if (remaining <= const Duration(days: 2)) return 0;
    if (remaining <= const Duration(days: 7)) return 1;
    return 2;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
