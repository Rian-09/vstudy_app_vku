import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/document_remote_datasource.dart';
import '../datasources/document_sync_queue.dart';
import '../local/documents_database.dart';
import '../repositories/progress_repository.dart';

@immutable
class StudyDocument {
  const StudyDocument({
    required this.id,
    required this.title,
    required this.subject,
    required this.author,
    required this.type,
    required this.size,
    required this.pages,
    required this.thumbnail,
    required this.isDownloaded,
    required this.isSaved,
    required this.progress,
    required this.category,
    required this.downloads,
    required this.updatedAt,
    this.filePath,
    this.userId,
  });

  final String id;
  final String title;
  final String subject;
  final String author;
  final String type;
  final String size;
  final int pages;
  final String thumbnail;
  final bool isDownloaded;
  final bool isSaved;
  final double progress;
  final DocumentCategory category;
  final int downloads;
  final String updatedAt;
  final String? filePath;
  final String? userId;

  factory StudyDocument.fromSupabase(Map<String, dynamic> json) {
    final subject = json['subjects'];
    final joinedSubject = subject is Map ? subject['name'] as String? : null;
    final subjectName =
        (json['subject'] as String?) ?? joinedSubject ?? 'Chưa phân loại';
    final categoryValue = json['category'] as String?;
    final category = categoryValue == 'course'
        ? DocumentCategory.course
        : DocumentCategory.exam;
    final fileType = (json['file_type'] as String? ?? 'Tài liệu').toUpperCase();
    final updatedAtValue = json['updated_at'] as String?;
    final updatedAt = updatedAtValue == null
        ? ''
        : _formatDate(DateTime.tryParse(updatedAtValue));

    return StudyDocument(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Tài liệu chưa đặt tên',
      subject: subjectName,
      author: 'V-Study',
      type: fileType,
      size: _formatSize(json['file_size'] ?? json['file_size_bytes']),
      pages: (json['page_count'] as num?)?.toInt() ?? 0,
      thumbnail: category == DocumentCategory.course
          ? 'assets/images/documents/slide_history.png'
          : 'assets/images/documents/exam_history.png',
      isDownloaded: false,
      isSaved: false,
      progress: 0,
      category: category,
      downloads: 0,
      updatedAt: updatedAt,
      filePath: json['file_path'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  factory StudyDocument.fromCache(CachedDocument row) {
    final category = row.category == 'course'
        ? DocumentCategory.course
        : DocumentCategory.exam;
    return StudyDocument(
      id: row.id,
      title: row.title ?? 'Tài liệu đã tải',
      subject: row.subject ?? 'Chưa phân loại',
      author: row.author ?? 'V-Study',
      type: row.type ?? 'PDF',
      size: row.size ?? '—',
      pages: row.pages ?? 0,
      thumbnail: row.thumbnail ?? 'assets/images/documents/exam_history.png',
      isDownloaded: true,
      isSaved: row.isSaved,
      progress: 0,
      category: category,
      downloads: row.downloads ?? 0,
      updatedAt: row.updatedAt ?? '',
      filePath: row.filePath,
    );
  }

  StudyDocument copyWith({
    bool? isDownloaded,
    bool? isSaved,
    double? progress,
    int? pages,
    String? filePath,
    String? userId,
  }) {
    return StudyDocument(
      id: id,
      title: title,
      subject: subject,
      author: author,
      type: type,
      size: size,
      pages: pages ?? this.pages,
      thumbnail: thumbnail,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isSaved: isSaved ?? this.isSaved,
      progress: progress ?? this.progress,
      category: category,
      downloads: downloads,
      updatedAt: updatedAt,
      filePath: filePath ?? this.filePath,
      userId: userId ?? this.userId,
    );
  }

  static String _formatSize(Object? bytes) {
    final value = (bytes as num?)?.toDouble();
    if (value == null || value <= 0) {
      return '—';
    }
    if (value >= 1024 * 1024) {
      return '${(value / 1024 / 1024).toStringAsFixed(1)}MB';
    }
    return '${(value / 1024).toStringAsFixed(0)}KB';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

enum DocumentCategory { course, exam }

class DocumentRepository extends ChangeNotifier {
  DocumentRepository._() : _documents = [];

  @visibleForTesting
  DocumentRepository.forTesting({
    List<StudyDocument> initialDocuments = const [],
  }) : _documents = List.of(initialDocuments);

  static final DocumentRepository instance = DocumentRepository._();

  final List<StudyDocument> _documents;
  final List<StudyDocument> _continueReadingDocuments = [];
  bool isLoading = false;
  String? loadError;

  Future<void> hydrateFromSupabase() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        _documents.clear();
        _continueReadingDocuments.clear();
        return;
      }
      final remote = await DocumentRemoteDataSource(client).fetchDocuments();
      final progressRepository = ProgressRepository(client);
      final progressRows = await progressRepository.getReadingProgress();
      final libraryRows = await client
          .from('document_progress')
          .select('document_id, is_saved, is_downloaded')
          .eq('owner_id', userId);
      final libraryByDocument = {
        for (final row in libraryRows)
          (row as Map)['document_id'] as String: Map<String, dynamic>.from(row),
      };
      final progressByDocument = {
        for (final row in progressRows) row['document_id'] as String: row,
      };
      Set<String> cachedIds = {};
      try {
        cachedIds = await DocumentsDatabase.instance.cachedDocumentIds();
      } catch (_) {
        // Remote lists must still work where the local Drift store is unavailable.
      }
      _documents
        ..clear()
        ..addAll(
          remote.map((document) {
            final progress = progressByDocument[document.id];
            final library = libraryByDocument[document.id];
            final cached = cachedIds.contains(document.id);
            final percent = (progress?['percent'] as num?)?.toDouble();
            return document.copyWith(
              isDownloaded: cached || library?['is_downloaded'] == true,
              progress: percent == null ? 0 : (percent / 100).clamp(0, 1),
              isSaved: library?['is_saved'] == true,
            );
          }),
        );
      final documentsById = {
        for (final document in _documents) document.id: document,
      };
      _continueReadingDocuments
        ..clear()
        ..addAll(
          progressRows
              .where((row) {
                final percent = (row['percent'] as num?)?.toDouble() ?? 0;
                return percent > 0 && percent < 100;
              })
              .map((row) {
                final document = documentsById[row['document_id']];
                if (document == null) return null;
                final percent = (row['percent'] as num).toDouble();
                return document.copyWith(progress: percent / 100);
              })
              .whereType<StudyDocument>()
              .take(3),
        );
    } catch (error) {
      loadError = error.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> hydrateFromCache() async {
    final cached = await DocumentsDatabase.instance.getCachedDocuments();
    final documents = cached
        .where((row) => row.title != null)
        .map(StudyDocument.fromCache)
        .toList(growable: false);
    _documents
      ..clear()
      ..addAll(documents);
    _continueReadingDocuments.clear();
    notifyListeners();
  }

  Future<StudyDocument> uploadDocument({
    required String title,
    required String subject,
    required String fileName,
    required String fileType,
    required Uint8List bytes,
  }) async {
    final uploaded = await DocumentRemoteDataSource(Supabase.instance.client)
        .uploadDocument(
          title: title,
          subject: subject,
          fileName: fileName,
          fileType: fileType,
          bytes: bytes,
        );
    _documents.insert(0, uploaded);
    notifyListeners();
    return uploaded;
  }

  Future<void> deleteDocument(String id) async {
    final document = findById(id);
    if (document == null || document.userId == null) return;
    await DocumentRemoteDataSource(Supabase.instance.client)
        .deleteDocument(id: document.id, filePath: document.filePath);
    _documents.removeWhere((item) => item.id == id);
    _continueReadingDocuments.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<String> getSignedUrl(String id) async {
    final document = findById(id);
    if (document == null || document.filePath == null) {
      throw StateError('Không tìm thấy đường dẫn tài liệu.');
    }
    return DocumentRemoteDataSource(Supabase.instance.client)
        .getSignedUrl(document.filePath!);
  }

  Future<void> updateReadingProgress({
    required String documentId,
    required int currentPage,
    required int totalPages,
  }) async {
    final document = findById(documentId);
    if (document == null) return;
    final progress = totalPages == 0
        ? 0.0
        : (currentPage / totalPages).clamp(0, 1).toDouble();
    final index = _documents.indexWhere((item) => item.id == documentId);
    if (index >= 0) {
      _documents[index] = _documents[index].copyWith(
        progress: progress,
        pages: totalPages > 0 ? totalPages : null,
      );
      final updatedDocument = _documents[index];
      _continueReadingDocuments.removeWhere((item) => item.id == documentId);
      if (progress > 0 && progress < 1) {
        _continueReadingDocuments.insert(0, updatedDocument);
        if (_continueReadingDocuments.length > 3) {
          _continueReadingDocuments.removeLast();
        }
      }
      notifyListeners();
    }
    await ProgressRepository(Supabase.instance.client).saveReadingProgress(
      documentId: documentId,
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }

  Future<void> recordReadingSession({
    required String documentId,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final document = findById(documentId);
    if (document == null) return;
    await ProgressRepository(Supabase.instance.client).recordSession(
      documentId: documentId,
      subject: document.subject,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  Future<void> syncPendingChanges() async {
    try {
      await _syncQueue.syncPending();
    } catch (_) {
      // A missing connection keeps operations queued for the next login.
    }
  }

  List<StudyDocument> get documents => List.unmodifiable(_documents);
  List<StudyDocument> get continueReadingDocuments =>
      List.unmodifiable(_continueReadingDocuments);

  List<StudyDocument> get savedOrDownloaded => List.unmodifiable(
    _documents.where(
      (document) =>
          document.isSaved || document.isDownloaded || document.progress > 0,
    ),
  );

  StudyDocument? findById(String id) {
    for (final document in _documents) {
      if (document.id == id) return document;
    }
    return null;
  }

  Future<StudyDocument?> getById(String id) async {
    final cached = findById(id);
    if (cached != null) return cached;
    final row = await DocumentRemoteDataSource(Supabase.instance.client)
        .getById(id);
    if (row == null) return null;
    final document = StudyDocument.fromSupabase(row);
    _documents.add(document);
    notifyListeners();
    return document;
  }

  void markDownloaded(String id) => _update(
    id,
    (document) => document.copyWith(isDownloaded: true, progress: 1),
  );

  void saveToLibrary(String id) =>
      _update(id, (document) => document.copyWith(isSaved: true));

  void toggleSaved(String id) =>
      _update(id, (document) => document.copyWith(isSaved: !document.isSaved));

  void updateProgress(String id, double progress) => _update(
    id,
    (document) => document.copyWith(progress: progress.clamp(0, 1).toDouble()),
  );

  void _update(
    String id,
    StudyDocument Function(StudyDocument document) update,
  ) {
    final index = _documents.indexWhere((document) => document.id == id);
    if (index < 0) return;
    _documents[index] = update(_documents[index]);
    notifyListeners();
    unawaited(_enqueueSync(_documents[index]));
  }

  Future<void> _enqueueSync(StudyDocument document) async {
    try {
      await _syncQueue.enqueue(document);
    } catch (_) {
      // Local UI state remains usable if Supabase is not initialized.
    }
  }

  DocumentSyncQueue get _syncQueue => _queue ??= DocumentSyncQueue(
    client: Supabase.instance.client,
    database: DocumentsDatabase.instance,
  );

  DocumentSyncQueue? _queue;

  void startAutoSync() {
    try {
      _syncQueue.startAutoSync();
    } catch (_) {
      // Supabase may be intentionally disabled in local/test builds.
    }
  }
}
