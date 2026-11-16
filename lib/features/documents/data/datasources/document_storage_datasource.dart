import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/documents_database.dart';
import '../models/document.dart';

class DocumentStorageDataSource {
  DocumentStorageDataSource({required this._client, required this._database});

  DocumentStorageDataSource.localOnly({required this._database})
    : _client = null;

  final SupabaseClient? _client;
  final DocumentsDatabase _database;

  Future<Uint8List> downloadAndCache({
    required String documentId,
    required String filePath,
    StudyDocument? document,
  }) async {
    final client = _client;
    final bytes = client == null
        ? Uint8List(0)
        : await client.storage.from('documents').download(filePath);
    await _database.savePdf(
      id: documentId,
      filePath: filePath,
      bytes: bytes,
      document: document,
    );
    return bytes;
  }

  Future<Uint8List?> readCached(String documentId) {
    return _database.readPdf(documentId);
  }

  Future<Uint8List?> getOnlineOrCached({
    required String documentId,
    required String? filePath,
  }) async {
    if (filePath == null || filePath.isEmpty) {
      return _database.readPdf(documentId);
    }
    try {
      return await downloadAndCache(documentId: documentId, filePath: filePath);
    } catch (_) {
      return _database.readPdf(documentId);
    }
  }
}
