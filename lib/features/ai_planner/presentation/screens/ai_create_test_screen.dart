import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/documents/data/models/document.dart';
import 'package:flutter_application_1/features/ai_planner/domain/usecases/ai_planner_usecases.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/ai_planner/presentation/widgets/ai_widgets.dart';

class AiCreateTestScreen extends StatefulWidget {
  const AiCreateTestScreen({super.key});
  @override
  State<AiCreateTestScreen> createState() => _AiCreateTestScreenState();
}

class AiPlayArgs {
  const AiPlayArgs({required this.examId, required this.timed});
  final String examId;
  final bool timed;
}

class _AiCreateTestScreenState extends State<AiCreateTestScreen> {
  String _count = '10';
  String _difficulty = 'Vừa';
  final Set<String> _questionTypes = {'Trắc nghiệm', 'Đúng / Sai'};
  final Set<String> _selectedDocuments = {};
  bool _loading = false;

  Future<void> _create() async {
    if (_selectedDocuments.isEmpty || _loading) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final firstDoc = DocumentRepository.instance.documents.firstWhere(
      (doc) => _selectedDocuments.contains(doc.id),
    );
    final examId = AiService.instance.generateMockTest(
      title: 'Đề ôn · ${firstDoc.subject}',
      questionCount: int.parse(_count),
      difficulty: _difficulty == 'Khó'
          ? 90
          : _difficulty == 'Dễ'
          ? 30
          : 60,
    );
    Navigator.of(context).pushNamed<void>(
      '/ai-quiz-play',
      arguments: AiPlayArgs(examId: examId, timed: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = DocumentRepository.instance.documents
        .where((doc) => doc.category == DocumentCategory.course)
        .take(2)
        .toList();
    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            const AiScreenHeader(
              title: 'Tạo đề ôn',
              subtitle: 'AI soạn đề từ tài liệu bạn chọn',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 21, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _formCard(
                      title: 'Nguồn tài liệu',
                      child: Column(
                        children: [
                          for (final doc in docs) _sourceTile(doc),
                          const SizedBox(height: 5),
                          Container(
                            height: 31,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF9CA8C0),
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Text(
                              '+ Thêm tài liệu',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: aiNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _formCard(
                      title: 'Số câu hỏi',
                      child: OptionChips(
                        items: const ['10', '20', '30', '40'],
                        selected: _count,
                        onSelected: (v) => setState(() => _count = v),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _formCard(
                      title: 'Độ khó',
                      child: OptionChips(
                        items: const ['Dễ', 'Vừa', 'Khó'],
                        selected: _difficulty,
                        onSelected: (v) => setState(() => _difficulty = v),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _formCard(
                      title: 'Dạng câu hỏi',
                      child: Column(
                        children: [
                          AiToggleRow(
                            title: 'Trắc nghiệm',
                            value: _questionTypes.contains('Trắc nghiệm'),
                            onChanged: (v) => setState(
                              () => v
                                  ? _questionTypes.add('Trắc nghiệm')
                                  : _questionTypes.remove('Trắc nghiệm'),
                            ),
                          ),
                          AiToggleRow(
                            title: 'Đúng / Sai',
                            value: _questionTypes.contains('Đúng / Sai'),
                            onChanged: (v) => setState(
                              () => v
                                  ? _questionTypes.add('Đúng / Sai')
                                  : _questionTypes.remove('Đúng / Sai'),
                            ),
                          ),
                          AiToggleRow(
                            title: 'Tự luận',
                            value: _questionTypes.contains('Tự luận'),
                            onChanged: (v) => setState(
                              () => v
                                  ? _questionTypes.add('Tự luận')
                                  : _questionTypes.remove('Tự luận'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
              child: PrimaryButton(
                label: _loading ? 'Đang tạo đề...' : 'Tạo đề với AI',
                onPressed: _selectedDocuments.isEmpty || _loading
                    ? null
                    : _create,
                height: 52,
                borderRadius: 24,
                showArrow: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formCard({required String title, required Widget child}) => Container(
    padding: const EdgeInsets.fromLTRB(15, 11, 15, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE7E3D8)),
      borderRadius: BorderRadius.circular(21),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: aiNavy,
          ),
        ),
        const SizedBox(height: 9),
        child,
      ],
    ),
  );

  Widget _sourceTile(StudyDocument doc) {
    final selected = _selectedDocuments.contains(doc.id);
    return InkWell(
      onTap: () => setState(
        () => selected
            ? _selectedDocuments.remove(doc.id)
            : _selectedDocuments.add(doc.id),
      ),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 39,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE8D8),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                doc.title
                    .replaceFirst('Slide ', '')
                    .replaceFirst('bài giảng ', ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: aiNavy,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? aiNavy : Colors.white,
                border: Border.all(
                  color: selected ? aiNavy : const Color(0xFFD8D2C4),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
