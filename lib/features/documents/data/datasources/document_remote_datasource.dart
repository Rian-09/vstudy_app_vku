import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/document.dart';

/// Reads published document metadata from Supabase.
///
/// Files remain private in Storage; the file path is retained for the later
/// signed-download flow and is never exposed as a public URL.
class DocumentRemoteDataSource {
  const DocumentRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<StudyDocument>> fetchPublishedDocuments() async {
    final rows = await _client
        .from('documents')
        .select('*, subjects(name)')
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return (rows as List)
        .map(
          (row) =>
              StudyDocument.fromSupabase(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);
  }
}
