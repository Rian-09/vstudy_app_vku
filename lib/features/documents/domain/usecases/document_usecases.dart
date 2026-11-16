import 'dart:typed_data';

import '../../data/models/document.dart';
import '../repositories/document_repository.dart';

class DocumentUseCases {
  const DocumentUseCases(this._repository);

  final DocumentRepositoryContract _repository;

  List<StudyDocument> get documents => _repository.documents;
  List<StudyDocument> get savedOrDownloaded => _repository.savedOrDownloaded;
  StudyDocument? findById(String id) => _repository.findById(id);
  Future<StudyDocument?> getById(String id) => _repository.getById(id);
  void markDownloaded(String id) => _repository.markDownloaded(id);
  void saveToLibrary(String id) => _repository.saveToLibrary(id);
  void toggleSaved(String id) => _repository.toggleSaved(id);
  void updateProgress(String id, double progress) =>
      _repository.updateProgress(id, progress);

  Future<StudyDocument> uploadDocument({
    required String title,
    required String subject,
    required String fileName,
    required String fileType,
    required Uint8List bytes,
  }) => _repository.uploadDocument(
    title: title,
    subject: subject,
    fileName: fileName,
    fileType: fileType,
    bytes: bytes,
  );

  Future<void> deleteDocument(String id) => _repository.deleteDocument(id);

  Future<String> getSignedUrl(String id) => _repository.getSignedUrl(id);
  Future<Uint8List?> getDocumentBytes(String id) =>
      _repository.getDocumentBytes(id);
  Future<void> downloadDocument(String id) => _repository.downloadDocument(id);

  Future<void> updateReadingProgress({
    required String documentId,
    required int currentPage,
    required int totalPages,
  }) => _repository.updateReadingProgress(
    documentId: documentId,
    currentPage: currentPage,
    totalPages: totalPages,
  );

  Future<void> recordReadingSession({
    required String documentId,
    required DateTime startedAt,
    required DateTime endedAt,
  }) => _repository.recordReadingSession(
    documentId: documentId,
    startedAt: startedAt,
    endedAt: endedAt,
  );
}
