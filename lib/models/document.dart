import 'package:flutter/foundation.dart';

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

  StudyDocument copyWith({
    bool? isDownloaded,
    bool? isSaved,
    double? progress,
  }) {
    return StudyDocument(
      id: id,
      title: title,
      subject: subject,
      author: author,
      type: type,
      size: size,
      pages: pages,
      thumbnail: thumbnail,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isSaved: isSaved ?? this.isSaved,
      progress: progress ?? this.progress,
      category: category,
      downloads: downloads,
      updatedAt: updatedAt,
    );
  }
}

enum DocumentCategory { course, exam }

class DocumentRepository extends ChangeNotifier {
  DocumentRepository._();

  static final DocumentRepository instance = DocumentRepository._();

  final List<StudyDocument> _documents = [
    StudyDocument(
      id: 'history-slides-2',
      title: 'Slide bài giảng Chương 2 - Lịch sử Đảng',
      subject: 'Lịch sử Đảng',
      author: 'GV: Nguyễn Thị Mai',
      type: 'Slide',
      size: '43MB',
      pages: 72,
      thumbnail: 'assets/images/documents/slide_history.png',
      isDownloaded: false,
      isSaved: true,
      progress: 0.8,
      category: DocumentCategory.course,
      downloads: 2093,
      updatedAt: '12/10/2024',
    ),
    StudyDocument(
      id: 'law-book-1',
      title: 'Slide Chương 1 - Pháp luật đại cương',
      subject: 'Pháp luật đại cương',
      author: 'GV: Nguyễn Thị Mai',
      type: 'Slide',
      size: '6.8MB',
      pages: 50,
      thumbnail: 'assets/images/documents/law_book.png',
      isDownloaded: false,
      isSaved: true,
      progress: 0.5,
      category: DocumentCategory.course,
      downloads: 592,
      updatedAt: '08/09/2024',
    ),
    StudyDocument(
      id: 'network-slides-3',
      title: 'Slide Chương 3 - Mạng máy tính',
      subject: 'Mạng máy tính',
      author: 'GV: Võ Văn Lương',
      type: 'Slide',
      size: '6.8MB',
      pages: 85,
      thumbnail: 'assets/images/documents/network_course.png',
      isDownloaded: false,
      isSaved: true,
      progress: 0.2,
      category: DocumentCategory.course,
      downloads: 1892,
      updatedAt: '12/10/2024',
    ),
    StudyDocument(
      id: 'philosophy-exam',
      title: 'Đề thi chuẩn kèm đáp án chi tiết môn Triết học Mác - Lênin',
      subject: 'Triết học Mác-Lênin',
      author: 'GV: Trần Văn Thái',
      type: 'Đề thi',
      size: '3MB',
      pages: 57,
      thumbnail: 'assets/images/documents/exam_history.png',
      isDownloaded: false,
      isSaved: false,
      progress: 0,
      category: DocumentCategory.exam,
      downloads: 2329,
      updatedAt: '12/08/2024',
    ),
    StudyDocument(
      id: 'software-report',
      title: 'Báo cáo đồ án chuyên ngành 2 (SE)',
      subject: 'Công nghệ phần mềm',
      author: 'GV: Võ Văn Lương',
      type: 'Báo cáo',
      size: '6.8MB',
      pages: 85,
      thumbnail: 'assets/images/documents/essay_report.png',
      isDownloaded: false,
      isSaved: false,
      progress: 0,
      category: DocumentCategory.exam,
      downloads: 1293,
      updatedAt: '12/10/2024',
    ),
    StudyDocument(
      id: 'computer-network-exam',
      title: 'Đề cương ôn tập Mạng máy tính',
      subject: 'Mạng máy tính',
      author: 'GV: Nguyễn Thị Mai',
      type: 'Đề cương',
      size: '8.2MB',
      pages: 72,
      thumbnail: 'assets/images/documents/algorithm_slides.png',
      isDownloaded: false,
      isSaved: false,
      progress: 0,
      category: DocumentCategory.exam,
      downloads: 837,
      updatedAt: '12/10/2024',
    ),
  ];

  List<StudyDocument> get documents => List.unmodifiable(_documents);

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
  }
}
