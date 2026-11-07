import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/features/quiz/data/models/quiz_models.dart';
import 'package:flutter_application_1/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/quiz/presentation/widgets/quiz_widgets.dart';

enum _QuizMode { practice, timed }

class ExamDetailScreen extends ConsumerStatefulWidget {
  const ExamDetailScreen({super.key, required this.examId});

  final String examId;

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  _QuizMode _mode = _QuizMode.practice;

  Future<void> _start() async {
    await Navigator.of(context).pushNamed<void>(
      '/play',
      arguments: QuizPlayArguments(
        examId: widget.examId,
        isTimed: _mode == _QuizMode.timed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.read(quizUseCasesProvider);
    final exam = quiz.examById(widget.examId);
    if (exam == null) {
      return AuthBackground(
        child: SafeArea(
          child: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Đề thi không còn khả dụng · Quay lại'),
            ),
          ),
        ),
      );
    }
    final subject = quiz.subjectById(exam.subjectId)!;
    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Quay lại',
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFFDFA841),
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      exam.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ExamInfoCard(subject: subject),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ExamParameterTile(
                            image: 'assets/images/quiz/exam_questions.png',
                            value: '${exam.questionCount}',
                            label: 'Câu hỏi',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ExamParameterTile(
                            image: 'assets/images/quiz/exam_duration.png',
                            value: '${exam.durationMinutes}',
                            label: 'Phút',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ExamParameterTile(
                            image: 'assets/images/quiz/exam_difficulty.png',
                            value: '${exam.difficulty}',
                            label: 'Mức độ',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        exam.chapterTitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: AuthColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Chế độ làm bài', style: AuthTextStyles.label),
                    const SizedBox(height: 12),
                    _QuizModeTile(
                      title: 'Luyện tập',
                      subtitle: 'Không tính giờ và không hiển thị đáp án',
                      image: 'assets/images/quiz/mode_practice.png',
                      selected: _mode == _QuizMode.practice,
                      onTap: () => setState(() => _mode = _QuizMode.practice),
                    ),
                    const SizedBox(height: 10),
                    _QuizModeTile(
                      title: 'Luyện tập',
                      subtitle: 'Tính giờ và kiểm tra đáp án mỗi câu',
                      image: 'assets/images/quiz/mode_timed.png',
                      selected: _mode == _QuizMode.timed,
                      onTap: () => setState(() => _mode = _QuizMode.timed),
                    ),
                    const SizedBox(height: 22),
                    const Text('Lưu ý', style: AuthTextStyles.label),
                    const SizedBox(height: 8),
                    const Text(
                      'Mỗi câu chỉ có một đáp án đúng\n'
                      'Có thể đánh dấu câu xem lại trước khi nộp\n'
                      'Hết giờ hệ thống tự động nộp bài',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 20 / 14,
                        color: AuthColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 94, 12),
              child: PrimaryButton(
                label: 'Làm ngay!',
                onPressed: _start,
                height: 48,
                borderRadius: 16,
                showArrow: false,
                enabledBackgroundColor: const Color(0xFFE5AB33),
                enabledForegroundColor: AuthColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamParameterTile extends StatelessWidget {
  const _ExamParameterTile({
    required this.image,
    required this.value,
    required this.label,
  });

  final String image;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AuthColors.navy),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, width: 27, height: 27, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            '$value $label',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Color(0xFF3B526B),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizModeTile extends StatelessWidget {
  const _QuizModeTile({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  image,
                  width: 54,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AuthColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AuthColors.navy : Colors.black,
                    width: selected ? 5 : 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
