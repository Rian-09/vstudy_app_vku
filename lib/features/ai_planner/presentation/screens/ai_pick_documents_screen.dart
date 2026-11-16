import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/ai_planner/data/models/ai_models.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';
import 'package:flutter_application_1/features/documents/data/models/document.dart';

class AiPickDocumentsScreen extends StatefulWidget {
  const AiPickDocumentsScreen({super.key});
  @override
  State<AiPickDocumentsScreen> createState() => _AiPickDocumentsScreenState();
}

class _AiPickDocumentsScreenState extends State<AiPickDocumentsScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'Tất cả';
  String _source = 'Tất cả';
  final _selected = <String>{};
  final _uploadedDocuments = <StudyDocument>[];
  bool _isLoadingDocuments = true;
  String? _documentsError;

  @override
  void initState() {
    super.initState();
    DocumentRepository.instance.addListener(_onDocumentsChanged);
    unawaited(_loadAvailableDocuments());
  }

  void _onDocumentsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAvailableDocuments() async {
    final repository = DocumentRepository.instance;
    _documentsError = null;
    try {
      await repository.hydrateFromCache();
    } catch (_) {
      // The remote catalog remains available without a local database.
    }
    try {
      await repository.hydrateFromSupabase();
    } catch (error) {
      _documentsError = error.toString();
    } finally {
      _isLoadingDocuments = false;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DocumentRepository.instance.removeListener(_onDocumentsChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx', 'ppt', 'pptx'],
    );
    if (files.isEmpty || !mounted) return;
    final imported = files
        .where((file) => file.path != null)
        .map((file) {
          final extension = file.extension?.toUpperCase() ?? 'FILE';
          final fileSize = file.lengthSync() ?? 0;
          return StudyDocument(
            id: 'local-${file.path.hashCode}',
            title: file.name,
            subject: 'Tài liệu từ thiết bị',
            author: 'Bạn',
            type: extension,
            size: fileSize < 1024 * 1024
                ? '${(fileSize / 1024).ceil()}KB'
                : '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB',
            pages: 0,
            thumbnail: 'assets/images/documents/slide_history.png',
            isDownloaded: true,
            isSaved: false,
            progress: 0,
            category: DocumentCategory.course,
            downloads: 0,
            updatedAt: '',
            filePath: file.path,
          );
        })
        .toList(growable: false);
    if (imported.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đọc được đường dẫn tệp đã chọn.')),
      );
      return;
    }
    setState(() {
      for (final doc in imported) {
        if (!_uploadedDocuments.any((item) => item.id == doc.id)) {
          _uploadedDocuments.add(doc);
        }
      }
      _source = 'Từ thiết bị';
      _selected.addAll(imported.map((doc) => doc.id));
    });
  }

  Future<void> _startSummary() async {
    final allDocuments = DocumentRepository.instance.documents.followedBy(
      _uploadedDocuments,
    );
    final selectedDocuments = allDocuments
        .where((doc) => _selected.contains(doc.id))
        .toList(growable: false);
    if (selectedDocuments.isEmpty) return;
    final selected = selectedDocuments.first;

    AiSummaryRequest request;
    if (selected.id.startsWith('local-')) {
      if (selected.type.toLowerCase() != 'pdf' || selected.filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tóm tắt tệp tải trực tiếp hiện hỗ trợ PDF. Tài liệu DOCX/PPTX cần được lưu vào kho và trích xuất văn bản trước.',
            ),
          ),
        );
        return;
      }
      try {
        final bytes = await File(selected.filePath!).readAsBytes();
        if (bytes.length > 15 * 1024 * 1024) {
          throw const FormatException('Tệp vượt giới hạn 15 MB.');
        }
        request = AiSummaryRequest(
          title: selected.title,
          fileName: selected.title,
          contentType: 'application/pdf',
          bytes: bytes,
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không đọc được tệp: $error')));
        return;
      }
    } else {
      request = AiSummaryRequest(
        title: selected.title,
        documentId: selected.id,
      );
    }
    if (!mounted) return;
    await Navigator.of(context).pushNamed<void>('/summary', arguments: request);
  }

  @override
  Widget build(BuildContext context) {
    final repository = DocumentRepository.instance;
    final allDocs = switch (_source) {
      'Đã lưu' => repository.savedOrDownloaded,
      'Từ thiết bị' => _uploadedDocuments,
      _ => repository.documents,
    };
    final subjects = allDocs.map((doc) => doc.subject).toSet().toList();
    final docs = allDocs.where((doc) {
      final matchesQuery = '${doc.title} ${doc.subject}'.toLowerCase().contains(
        _query.toLowerCase(),
      );
      final matchesCategory = _category == 'Tất cả' || doc.subject == _category;
      return matchesQuery && matchesCategory;
    }).toList();

    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            const AiScreenHeader(
              title: 'Tóm tắt tài liệu',
              subtitle: 'Chọn tài liệu muốn tóm tắt.',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 13, 22, 0),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFF8792AB),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (value) => setState(() => _query = value),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: aiNavy,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tìm tên tài liệu...',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF8A93AA),
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 51,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip('Tất cả'),
                  _categoryChip('Đã lưu'),
                  _categoryChip('Từ thiết bị'),
                  for (final subject in subjects) _categoryChip(subject),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 11),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tài liệu của bạn',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: aiNavy,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                itemCount: docs.isEmpty ? 1 : docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (_, index) {
                  if (docs.isEmpty) {
                    if (_isLoadingDocuments) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (_documentsError != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Không tải được kho tài liệu.'),
                            TextButton(
                              onPressed: () {
                                setState(() => _isLoadingDocuments = true);
                                unawaited(_loadAvailableDocuments());
                              },
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(child: Text('Chưa có tài liệu phù hợp.')),
                    );
                  }
                  final doc = docs[index];
                  return DocCheckTile(
                    document: doc,
                    selected: _selected.contains(doc.id),
                    onChanged: (value) => setState(() {
                      if (value) {
                        _selected
                          ..clear()
                          ..add(doc.id);
                      } else {
                        _selected.remove(doc.id);
                      }
                    }),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 3, 22, 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .25),
                      border: Border.all(
                        color: const Color(0xFF99A6C1),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: _pickDocuments,
                      child: const Text(
                        '+ Chọn tài liệu từ thiết bị (PDF, DOCX, PPTX)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: aiNavy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _selected.isEmpty
                        ? 'Chưa chọn tài liệu'
                        : 'Đã chọn 1 tài liệu',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF8A93AA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Tóm tắt tài liệu',
                    onPressed: _selected.isEmpty ? null : _startSummary,
                    height: 52,
                    borderRadius: 22,
                    showArrow: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label) {
    final isSource = const {'Tất cả', 'Đã lưu', 'Từ thiết bị'}.contains(label);
    final selected = isSource ? _source == label : _category == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : aiNavy,
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() {
          if (isSource) {
            _source = label;
            _category = 'Tất cả';
          } else {
            _category = label;
          }
        }),
        selectedColor: aiNavy,
        backgroundColor: const Color(0xFFEFE8D8),
        side: BorderSide.none,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
