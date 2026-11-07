import '../../data/models/document.dart';

abstract interface class DocumentRepositoryContract {
  List<StudyDocument> get documents;
  List<StudyDocument> get savedOrDownloaded;
  StudyDocument? findById(String id);
  void markDownloaded(String id);
  void saveToLibrary(String id);
  void toggleSaved(String id);
  void updateProgress(String id, double progress);
}
