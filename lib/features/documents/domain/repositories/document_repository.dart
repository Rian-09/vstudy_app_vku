import 'dart:typed_data';

import '../../data/models/document.dart';

abstract interface class DocumentRepositoryContract {
  List<StudyDocument> get documents;
  List<StudyDocument> get savedOrDownloaded;
  StudyDocument? findById(String id);
  Future<StudyDocument?> getById(String id);
  void markDownloaded(String id);
  void saveToLibrary(String id);
  void toggleSaved(String id);
  void updateProgress(String id, double progress);
  Future<StudyDocument> uploadDocument({
    required String title,
    required String subject,
    required String fileName,
    required String fileType,
    required Uint8List bytes,
  });
  Future<void> deleteDocument(String id);
  Future<String> getSignedUrl(String id);
  Future<Uint8List?> getDocumentBytes(String id);
  Future<void> downloadDocument(String id);
  Future<void> updateReadingProgress({
    required String documentId,
    required int currentPage,
    required int totalPages,
  });
  Future<void> recordReadingSession({
    required String documentId,
    required DateTime startedAt,
    required DateTime endedAt,
  });
}
