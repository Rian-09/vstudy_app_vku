import 'package:flutter/material.dart';

import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';

enum _ReviewFilter { all, wrong }

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen({super.key, required this.result});

  final QuizResult result;

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  _ReviewFilter _filter = _ReviewFilter.all;

  @override
  Widget build(BuildContext context) {
    final service = QuizService.instance;
    final exam = service.examById(widget.result.examId);
    final subject = exam == null ? null : service.subjectById(exam.subjectId);
    final questions = service.questionsForExam(widget.result.examId);
    final filteredQuestions = [
      for (var index = 0; index < questions.length; index++)
        if (_filter == _ReviewFilter.all ||
            widget.result.answers[index] != questions[index].correctIndex)
          (index: index, question: questions[index]),
    ];

    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            _ReviewHeader(
              subtitle:
                  '${subject?.name ?? 'Quiz'} • ${exam?.chapterTitle ?? ''}',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _ReviewFilterChip(
                      label: 'Tất cả (${questions.length})',
                      selected: _filter == _ReviewFilter.all,
                      onTap: () => setState(() => _filter = _ReviewFilter.all),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ReviewFilterChip(
                      label:
                          'Câu sai (${questions.length - widget.result.correctCount})',
                      selected: _filter == _ReviewFilter.wrong,
                      onTap: () =>
                          setState(() => _filter = _ReviewFilter.wrong),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredQuestions.isEmpty
                  ? Center(
                      child: Text(
                        _filter == _ReviewFilter.wrong
                            ? 'Không có câu sai trong bài làm này.'
                            : 'Chưa có câu hỏi.',
                        style: AuthTextStyles.body,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: filteredQuestions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, listIndex) {
                        final item = filteredQuestions[listIndex];
                        final answer = widget.result.answers[item.index];
                        return _ReviewQuestionCard(
                          number: item.index + 1,
                          question: item.question,
                          selectedAnswer: answer,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.subtitle, required this.onBack});

  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Quay lại',
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đáp án & Lời giải',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    height: 21 / 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _ReviewFilterChip extends StatelessWidget {
  const _ReviewFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AuthColors.navy : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 34,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AuthColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewQuestionCard extends StatelessWidget {
  const _ReviewQuestionCard({
    required this.number,
    required this.question,
    required this.selectedAnswer,
  });

  final int number;
  final Question question;
  final int? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswer == question.correctIndex;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isCorrect ? const Color(0xFFB8F1D2) : const Color(0xFFFFCBD3),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _ReviewTag(
                      label: 'Câu $number • ${question.topic}',
                      foreground: const Color(0xFF334155),
                      background: const Color(0xFFF1F5F9),
                    ),
                    _ReviewTag(
                      label: selectedAnswer == null
                          ? 'Bỏ qua'
                          : isCorrect
                          ? 'Trả lời đúng'
                          : 'Trả lời sai',
                      foreground: selectedAnswer == null
                          ? const Color(0xFFB45309)
                          : isCorrect
                          ? const Color(0xFF059669)
                          : const Color(0xFFE11D48),
                      background: selectedAnswer == null
                          ? const Color(0xFFFEF3C7)
                          : isCorrect
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFE4E6),
                    ),
                  ],
                ),
              ),
              Text(
                '#Q${number.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: AuthColors.grayBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 19 / 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < question.options.length; index++) ...[
            if (index > 0) const SizedBox(height: 6),
            _ReviewOption(
              letter: String.fromCharCode(65 + index),
              text: question.options[index],
              isCorrect: index == question.correctIndex,
              isSelected: index == selectedAnswer,
            ),
          ],
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF101127),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.explanation,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                height: 16 / 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewOption extends StatelessWidget {
  const _ReviewOption({
    required this.letter,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
  });

  final String letter;
  final String text;
  final bool isCorrect;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? const Color(0xFF059669)
        : isSelected
        ? const Color(0xFFE11D48)
        : const Color(0xFFF1F5F9);
    final background = isCorrect
        ? const Color(0xFFECFDF5)
        : isSelected
        ? const Color(0xFFFFF1F2)
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: isCorrect
              ? const Color(0xFFD1FAE5)
              : isSelected
              ? const Color(0xFFFFE4E6)
              : const Color(0xFFF1F5F9),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: color,
            child: Text(
              letter,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isCorrect || isSelected
                    ? Colors.white
                    : AuthColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                height: 16 / 11,
                color: isCorrect
                    ? const Color(0xFF047857)
                    : isSelected
                    ? const Color(0xFFBE123C)
                    : const Color(0xFF64748B),
                fontWeight: isCorrect || isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_circle, color: Color(0xFF059669), size: 16),
          if (isSelected && !isCorrect)
            const Icon(Icons.cancel, color: Color(0xFFE11D48), size: 16),
        ],
      ),
    );
  }
}

class _ReviewTag extends StatelessWidget {
  const _ReviewTag({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
