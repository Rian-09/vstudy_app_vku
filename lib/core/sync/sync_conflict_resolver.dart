class SyncVersioned<T> {
  const SyncVersioned({required this.value, required this.updatedAt});

  final T value;
  final DateTime updatedAt;
}

/// Conflict policy for offline records: the newest UTC timestamp wins.
/// If timestamps are equal, the incoming value wins deterministically.
class SyncConflictResolver {
  const SyncConflictResolver();

  SyncVersioned<T> lastWriteWins<T>(
    SyncVersioned<T> local,
    SyncVersioned<T> incoming,
  ) {
    if (incoming.updatedAt.isBefore(local.updatedAt)) return local;
    return incoming;
  }
}
