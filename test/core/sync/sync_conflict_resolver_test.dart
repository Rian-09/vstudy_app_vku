import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/sync/sync_conflict_resolver.dart';

void main() {
  const resolver = SyncConflictResolver();
  final base = DateTime.utc(2026, 11, 16, 10);

  test('keeps local value when incoming version is older', () {
    final local = SyncVersioned(value: 'local', updatedAt: base);
    final incoming = SyncVersioned(
      value: 'old remote',
      updatedAt: base.subtract(const Duration(minutes: 1)),
    );

    expect(resolver.lastWriteWins(local, incoming).value, 'local');
  });

  test('takes incoming value when it is newer', () {
    final local = SyncVersioned(value: 'local', updatedAt: base);
    final incoming = SyncVersioned(
      value: 'new remote',
      updatedAt: base.add(const Duration(minutes: 1)),
    );

    expect(resolver.lastWriteWins(local, incoming).value, 'new remote');
  });

  test('uses incoming value when timestamps are equal', () {
    final local = SyncVersioned(value: 'local', updatedAt: base);
    final incoming = SyncVersioned(value: 'remote', updatedAt: base);

    expect(resolver.lastWriteWins(local, incoming).value, 'remote');
  });
}
