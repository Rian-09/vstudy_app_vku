import 'dart:typed_data';

import '../../domain/repositories/document_repository.dart';
import '../datasources/document_storage_datasource.dart';
import '../models/document.dart';

class DocumentRepositoryImpl implements DocumentRepositoryContract {
  DocumentRepositoryImpl(this._dataSource, this._storageDataSource);

  final DocumentRepository _dataSource;
  final DocumentStorageDataSource _storageDataSource;

  @override
  List<StudyDocument> get documents => _dataSource.documents;

  @override
  List<StudyDocument> get savedOrDownloaded => _dataSource.savedOrDownloaded;

  @override
  StudyDocument? findById(String id) => _dataSource.findById(id);

  @override
  Future<StudyDocument?> getById(String id) => _dataSource.getById(id);

  @override
  void markDownloaded(String id) => _dataSource.markDownloaded(id);

  @override
  void saveToLibrary(String id) => _dataSource.saveToLibrary(id);

  @override
  void toggleSaved(String id) => _dataSource.toggleSaved(id);

  @override
  void updateProgress(String id, double progress) =>
      _dataSource.updateProgress(id, progress);

  @override
  Future<StudyDocument> uploadDocument({
    required String title,
    required String subject,
    required String fileName,
    required String fileType,
    required Uint8List bytes,
  }) => _dataSource.uploadDocument(
    title: title,
    subject: subject,
    fileName: fileName,
    fileType: fileType,
    bytes: bytes,
  );

  @override
  Future<void> deleteDocument(String id) => _dataSource.deleteDocument(id);

  @override
  Future<String> getSignedUrl(String id) => _dataSource.getSignedUrl(id);

  @override
  Future<Uint8List?> getDocumentBytes(String id) async {
    final document = _dataSource.findById(id);
    if (document == null) return null;
    return _storageDataSource.getOnlineOrCached(
      documentId: id,
      filePath: document.filePath,
    );
  }

  @override
  Future<void> downloadDocument(String id) async {
    final document = _dataSource.findById(id);
    if (document == null ||
        document.filePath == null ||
        document.filePath!.isEmpty) {
      throw StateError('Tài liệu này chưa có file trên máy chủ.');
    }
    await _storageDataSource.downloadAndCache(
      documentId: id,
      filePath: document.filePath!,
      document: document,
    );
  }

  @override
  Future<void> updateReadingProgress({
    required String documentId,
    required int currentPage,
    required int totalPages,
  }) => _dataSource.updateReadingProgress(
    documentId: documentId,
    currentPage: currentPage,
    totalPages: totalPages,
  );

  @override
  Future<void> recordReadingSession({
    required String documentId,
    required DateTime startedAt,
    required DateTime endedAt,
  }) => _dataSource.recordReadingSession(
    documentId: documentId,
    startedAt: startedAt,
    endedAt: endedAt,
  );
}
