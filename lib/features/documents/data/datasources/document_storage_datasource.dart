import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/documents_database.dart';

class DocumentStorageDataSource {
  DocumentStorageDataSource({required this._client, required this._database});

  final SupabaseClient _client;
  final DocumentsDatabase _database;

  Future<Uint8List> downloadAndCache({
    required String documentId,
    required String filePath,
  }) async {
    final bytes = await _client.storage.from('documents').download(filePath);
    await _database.savePdf(id: documentId, filePath: filePath, bytes: bytes);
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
