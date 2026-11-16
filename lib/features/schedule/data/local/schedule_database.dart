import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/entities/schedule_event.dart';

part 'schedule_database.g.dart';

class CachedScheduleEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subject => text()();
  TextColumn get type => text()();
  TextColumn get format => text()();
  DateTimeColumn get startsAt => dateTime()();
  DateTimeColumn get endsAt => dateTime()();
  TextColumn get location => text()();
  TextColumn get note => text()();
  TextColumn get repeatRule => text()();
  TextColumn get reminder => text()();
  TextColumn get checklistJson => text()();
  TextColumn get status => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ScheduleSyncOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

@DriftDatabase(tables: [CachedScheduleEvents, ScheduleSyncOperations])
class ScheduleDatabase extends _$ScheduleDatabase {
  static final instance = ScheduleDatabase();

  ScheduleDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'vstudy_schedule'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
  );

  Future<void> upsertEvent(ScheduleEvent event) {
    return into(cachedScheduleEvents).insertOnConflictUpdate(
      CachedScheduleEventsCompanion.insert(
        id: event.id,
        title: event.title,
        subject: event.subject,
        type: event.type.name,
        format: event.format.name,
        startsAt: event.startsAt.toUtc(),
        endsAt: event.endsAt.toUtc(),
        location: event.location,
        note: event.note,
        repeatRule: event.repeat,
        reminder: event.reminder,
        checklistJson: jsonEncode(event.checklist),
        status: event.status.name,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<List<CachedScheduleEvent>> getEvents() =>
      (select(cachedScheduleEvents)..orderBy([(row) => OrderingTerm(expression: row.startsAt)])).get();

  Future<void> deleteEvent(String id) =>
      (delete(cachedScheduleEvents)..where((row) => row.id.equals(id))).go();

  Future<int> enqueue({
    required String entityId,
    required String operation,
    required String payload,
    required DateTime updatedAt,
  }) => into(scheduleSyncOperations).insert(
    ScheduleSyncOperationsCompanion.insert(
      entityId: entityId,
      operation: operation,
      payload: payload,
      updatedAt: updatedAt,
    ),
  );

  Future<List<ScheduleSyncOperation>> pendingOperations() =>
      (select(scheduleSyncOperations)
            ..where((row) => row.status.equals('pending'))
            ..orderBy([(row) => OrderingTerm(expression: row.updatedAt)]))
          .get();

  Future<void> removeOperation(int id) =>
      (delete(scheduleSyncOperations)..where((row) => row.id.equals(id))).go();

  Future<void> markOperationFailed(int id, {required int attempts}) async {
    final delaySeconds = (1 << attempts.clamp(0, 5)).clamp(1, 30);
    await (update(scheduleSyncOperations)..where((row) => row.id.equals(id))).write(
      ScheduleSyncOperationsCompanion(
        attempts: Value(attempts + 1),
        nextRetryAt: Value(
          DateTime.now().toUtc().add(Duration(seconds: delaySeconds)),
        ),
      ),
    );
  }
}

