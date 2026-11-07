import '../../data/models/document.dart';
import '../repositories/document_repository.dart';

class DocumentUseCases {
  const DocumentUseCases(this._repository);

  final DocumentRepositoryContract _repository;

  List<StudyDocument> get documents => _repository.documents;
  List<StudyDocument> get savedOrDownloaded => _repository.savedOrDownloaded;
  StudyDocument? findById(String id) => _repository.findById(id);
  void markDownloaded(String id) => _repository.markDownloaded(id);
  void saveToLibrary(String id) => _repository.saveToLibrary(id);
  void toggleSaved(String id) => _repository.toggleSaved(id);
  void updateProgress(String id, double progress) =>
      _repository.updateProgress(id, progress);
}
