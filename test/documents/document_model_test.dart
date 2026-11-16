import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/documents/data/models/document.dart';

void main() {
  group('StudyDocument.fromSupabase', () {
    test('maps published course metadata and formats file size/date', () {
      final document = StudyDocument.fromSupabase({
        'id': 'doc-1',
        'title': 'Slide chương 1',
        'category': 'course',
        'file_type': 'pdf',
        'file_path': 'subjects/philosophy/doc-1.pdf',
        'file_size_bytes': 2097152,
        'page_count': 42,
        'updated_at': '2026-11-16T08:30:00Z',
        'subjects': {'name': 'Triết học'},
      });

      expect(document.id, 'doc-1');
      expect(document.subject, 'Triết học');
      expect(document.category, DocumentCategory.course);
      expect(document.type, 'PDF');
      expect(document.size, '2.0MB');
      expect(document.pages, 42);
      expect(document.updatedAt, '16/11/2026');
      expect(document.filePath, 'subjects/philosophy/doc-1.pdf');
      expect(document.isDownloaded, isFalse);
    });

    test('uses safe defaults when optional server fields are absent', () {
      final document = StudyDocument.fromSupabase({
        'id': 'doc-2',
        'title': 'Tài liệu pháp luật',
        'category': 'review',
      });

      expect(document.subject, 'Chưa phân loại');
      expect(document.type, 'TÀI LIỆU');
      expect(document.size, '—');
      expect(document.pages, 0);
      expect(document.category, DocumentCategory.exam);
      expect(document.updatedAt, '');
    });
  });

  test('copyWith preserves storage metadata while updating offline state', () {
    const original = StudyDocument(
      id: 'doc-3',
      title: 'Tài liệu',
      subject: 'Môn học',
      author: 'V-Study',
      type: 'PDF',
      size: '1MB',
      pages: 10,
      thumbnail: 'thumb.png',
      isDownloaded: false,
      isSaved: false,
      progress: 0,
      category: DocumentCategory.course,
      downloads: 0,
      updatedAt: '16/11/2026',
      filePath: 'subjects/doc-3.pdf',
    );

    final downloaded = original.copyWith(isDownloaded: true, progress: 1);

    expect(downloaded.isDownloaded, isTrue);
    expect(downloaded.progress, 1);
    expect(downloaded.filePath, original.filePath);
    expect(downloaded.title, original.title);
  });
}
