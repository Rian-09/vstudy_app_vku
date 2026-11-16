import 'dart:convert';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/documents_database.dart';
import '../models/document.dart';

class DocumentSyncQueue {
  DocumentSyncQueue({required this.client, required this.database});

  final SupabaseClient client;
  final DocumentsDatabase database;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startAutoSync() {
    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        unawaited(syncPending());
      }
    });
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> enqueue(StudyDocument document) {
    return database.enqueueSyncOperation(
      entityType: 'document_progress',
      entityId: document.id,
      operation: 'upsert',
      payload: jsonEncode({
        'document_id': document.id,
        'progress': document.progress,
        'is_saved': document.isSaved,
        'is_downloaded': document.isDownloaded,
      }),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> syncPending() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final operations = await database.getPendingSyncOperations();
    for (final operation in operations) {
      try {
        final payload =
            Map<String, dynamic>.from(jsonDecode(operation.payload) as Map)
              ..['owner_id'] = userId
              ..['updated_at'] = operation.updatedAt.toIso8601String();
        await client
            .from('document_progress')
            .upsert(payload, onConflict: 'owner_id,document_id');
        await database.removeSyncOperation(operation.id);
      } catch (_) {
        await database.markSyncOperationFailed(operation.id);
      }
    }
  }
}
