import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressRepository {
  const ProgressRepository(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> getReadingProgress() async {
    final userId = _requireUserId();
    final rows = await _client
        .from('reading_progress')
        .select(
          'document_id, current_page, total_pages, percent, is_finished, last_opened_at',
        )
        .eq('user_id', userId)
        .order('last_opened_at', ascending: false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getContinueReading({int limit = 3}) async {
    final userId = _requireUserId();
    final rows = await _client
        .from('reading_progress')
        .select('*, documents(*)')
        .eq('user_id', userId)
        .gt('percent', 0)
        .lt('percent', 100)
        .order('last_opened_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<void> saveReadingProgress({
    required String documentId,
    required int currentPage,
    required int totalPages,
  }) async {
    final userId = _requireUserId();
    final safeTotalPages = totalPages < 0 ? 0 : totalPages;
    final safeCurrentPage = currentPage < 0
        ? 0
        : safeTotalPages > 0 && currentPage > safeTotalPages
        ? safeTotalPages
        : currentPage;
    final percent = safeTotalPages == 0
        ? 0.0
        : (safeCurrentPage / safeTotalPages * 100).clamp(0, 100).toDouble();
    await _client.from('reading_progress').upsert({
      'user_id': userId,
      'document_id': documentId,
      'current_page': safeCurrentPage,
      'total_pages': safeTotalPages,
      'percent': percent,
      'last_opened_at': DateTime.now().toUtc().toIso8601String(),
      'is_finished': safeTotalPages > 0 && safeCurrentPage >= safeTotalPages,
    }, onConflict: 'user_id,document_id');
  }

  Future<void> recordSession({
    required String documentId,
    required String subject,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final userId = _requireUserId();
    final seconds = endedAt.difference(startedAt).inSeconds;
    if (seconds <= 0) return;
    await _client.from('study_sessions').insert({
      'user_id': userId,
      'document_id': documentId,
      'subject': subject,
      'started_at': startedAt.toUtc().toIso8601String(),
      'ended_at': endedAt.toUtc().toIso8601String(),
      'duration_minutes': seconds ~/ 60,
      'activity_type': 'read',
    });
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('Vui lòng đăng nhập để tiếp tục.');
    return userId;
  }
}
