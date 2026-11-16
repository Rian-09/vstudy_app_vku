import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/schedule/data/local/schedule_database.dart';
import 'package:flutter_application_1/features/schedule/domain/entities/schedule_event.dart';

void main() {
  late ScheduleDatabase database;

  setUp(() {
    database = ScheduleDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores schedule locally and queues an upsert', () async {
    final event = ScheduleEvent(
      id: 'event-1',
      title: 'Ôn tập',
      subject: 'Triết học',
      type: ScheduleEventType.selfStudy,
      format: ScheduleEventFormat.selfStudy,
      startsAt: DateTime(2026, 11, 16, 19),
      endsAt: DateTime(2026, 11, 16, 21),
      location: 'Thư viện',
      note: '',
      repeat: 'Không lặp lại',
      reminder: 'Không nhắc',
      checklist: [],
    );

    await database.upsertEvent(event);
    await database.enqueue(
      entityId: event.id,
      operation: 'upsert',
      payload: '{"id":"event-1"}',
      updatedAt: DateTime.utc(2026, 11, 16, 12),
    );

    expect((await database.getEvents()).single.title, 'Ôn tập');
    expect((await database.pendingOperations()).single.entityId, 'event-1');
  });

  test('failed operation gets retry metadata', () async {
    final id = await database.enqueue(
      entityId: 'event-2',
      operation: 'delete',
      payload: '{"id":"event-2"}',
      updatedAt: DateTime.now().toUtc(),
    );

    await database.markOperationFailed(id, attempts: 0);
    final operation = (await database.pendingOperations()).single;

    expect(operation.attempts, 1);
    expect(operation.nextRetryAt, isNotNull);
  });
}
