import '../../domain/repositories/document_repository.dart';
import '../models/document.dart';

class DocumentRepositoryImpl implements DocumentRepositoryContract {
  DocumentRepositoryImpl(this._dataSource);

  final DocumentRepository _dataSource;

  @override
  List<StudyDocument> get documents => _dataSource.documents;

  @override
  List<StudyDocument> get savedOrDownloaded => _dataSource.savedOrDownloaded;

  @override
  StudyDocument? findById(String id) => _dataSource.findById(id);

  @override
  void markDownloaded(String id) => _dataSource.markDownloaded(id);

  @override
  void saveToLibrary(String id) => _dataSource.saveToLibrary(id);

  @override
  void toggleSaved(String id) => _dataSource.toggleSaved(id);

  @override
  void updateProgress(String id, double progress) =>
      _dataSource.updateProgress(id, progress);
}
