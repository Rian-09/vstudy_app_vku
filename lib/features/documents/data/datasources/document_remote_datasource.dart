import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/document.dart';

/// Lưu metadata trên Postgres và tệp trong private Storage.
class DocumentRemoteDataSource {
  const DocumentRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<StudyDocument>> fetchDocuments() async {
    final rows = await _client
        .from('documents')
        .select('*, subjects(name)')
        .order('created_at', ascending: false);

    return (rows as List)
        .map(
          (row) =>
              StudyDocument.fromSupabase(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);
  }

  Future<StudyDocument> uploadDocument({
    required String title,
    required String subject,
    required String fileName,
    required String fileType,
    required Uint8List bytes,
  }) async {
    final userId = _requireUserId();
    final extension = fileName.contains('.') ? fileName.split('.').last : 'bin';
    final objectPath =
        '$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';
    final storage = _client.storage.from('documents');
    await storage.uploadBinary(
      objectPath,
      bytes,
      fileOptions: FileOptions(
        upsert: false,
        contentType: _contentType(fileType),
      ),
    );

    try {
      final row = await _client
          .from('documents')
          .insert({
            'user_id': userId,
            'title': title.trim().isEmpty ? fileName : title.trim(),
            'subject': subject.trim().isEmpty
                ? 'Chưa phân loại'
                : subject.trim(),
            'file_path': objectPath,
            'file_type': fileType.toLowerCase(),
            'file_size': bytes.length,
            'page_count': null,
            'extracted_text': null,
            'is_published': false,
          })
          .select('*, subjects(name)')
          .single();
      return StudyDocument.fromSupabase(Map<String, dynamic>.from(row));
    } catch (_) {
      await storage.remove([objectPath]);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final row = await _client
        .from('documents')
        .select('*, subjects(name)')
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Future<String> getSignedUrl(String filePath) {
    return _client.storage.from('documents').createSignedUrl(filePath, 300);
  }

  Future<void> deleteDocument({
    required String id,
    required String? filePath,
  }) async {
    await _client.from('documents').delete().eq('id', id);
    if (filePath != null && filePath.isNotEmpty) {
      await _client.storage.from('documents').remove([filePath]);
    }
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Vui lòng đăng nhập để tải tài liệu.');
    return userId;
  }

  String _contentType(String fileType) => switch (fileType.toLowerCase()) {
    'pdf' => 'application/pdf',
    'docx' =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'ppt' => 'application/vnd.ms-powerpoint',
    'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    _ => 'application/octet-stream',
  };
}
