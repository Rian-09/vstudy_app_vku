import 'package:flutter/material.dart';

import '../../models/document.dart';
import '../../services/ai_service.dart';
import '../../widgets/auth_widgets.dart';
import 'widgets/ai_widgets.dart';

class AiPickDocumentsScreen extends StatefulWidget {
  const AiPickDocumentsScreen({super.key});
  @override
  State<AiPickDocumentsScreen> createState() => _AiPickDocumentsScreenState();
}

class _AiPickDocumentsScreenState extends State<AiPickDocumentsScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'Tất cả';
  final _selected = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allDocs = DocumentRepository.instance.documents
        .where((doc) => doc.category == DocumentCategory.course)
        .toList();
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
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (_, index) {
                  final doc = docs[index];
                  return DocCheckTile(
                    document: doc,
                    selected: _selected.contains(doc.id),
                    onChanged: (value) => setState(
                      () => value
                          ? _selected.add(doc.id)
                          : _selected.remove(doc.id),
                    ),
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
                    child: const Text(
                      '+ Tải tài liệu mới (PDF, DOCX, PPTX)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: aiNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _selected.isEmpty
                        ? 'Chưa chọn tài liệu'
                        : 'Đã chọn ${_selected.length} tài liệu',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF8A93AA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Tóm tắt tài liệu',
                    onPressed: _selected.isEmpty
                        ? null
                        : () {
                            final selected = DocumentRepository
                                .instance
                                .documents
                                .where((doc) => _selected.contains(doc.id))
                                .toList();
                            final doc = selected.first;
                            Navigator.of(context).pushNamed<void>(
                              '/summary',
                              arguments: AiService.instance.summaryFor(
                                doc.title,
                              ),
                            );
                          },
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
    final selected = _category == label;
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
        onSelected: (_) => setState(() => _category = label),
        selectedColor: aiNavy,
        backgroundColor: const Color(0xFFEFE8D8),
        side: BorderSide.none,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
