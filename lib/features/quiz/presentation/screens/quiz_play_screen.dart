import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/features/quiz/data/models/quiz_models.dart';
import 'package:flutter_application_1/features/quiz/domain/usecases/quiz_usecases.dart';
import 'package:flutter_application_1/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/core/widgets/profile_dialogs.dart';
import 'submit_confirm_dialog.dart';
import 'quiz_result_screen.dart';

const _playGreen = Color(0xFF059669);
const _playGreenTint = Color(0xFFECFDF5);
const _playRed = Color(0xFFE11D48);
const _playRedTint = Color(0xFFFFF1F2);

class QuizPlayScreen extends ConsumerStatefulWidget {
  const QuizPlayScreen({super.key, required this.examId, this.isTimed = false});

  final String examId;
  final bool isTimed;

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  late final QuizUseCases _quiz;
  final Set<int> _bookmarkedQuestions = {};
  Timer? _timer;
  late int _remainingSeconds;
  bool _isShowingSubmit = false;

  Exam get _exam => _quiz.activeExam!;
  Question get _question => _quiz.currentQuestion!;
  int get _questionCount => _exam.questions.length;
  int get _currentIndex => _quiz.currentQuestionIndex;
  bool get _isLastQuestion => _currentIndex == _questionCount - 1;

  @override
  void initState() {
    super.initState();
    _quiz = ref.read(quizUseCasesProvider);
    _quiz.startSession(widget.examId, timed: widget.isTimed);
    _remainingSeconds = _exam.durationMinutes * 60;
    if (widget.isTimed) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_remainingSeconds <= 1) {
          setState(() => _remainingSeconds = 0);
          _timer?.cancel();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _submitQuiz();
          });
        } else {
          setState(() => _remainingSeconds--);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _exitQuiz() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Thoát bài làm?',
        message: 'Tiến độ làm bài hiện tại sẽ không được lưu.',
        cancelLabel: 'Tiếp tục làm',
        confirmLabel: 'Thoát',
        confirmColor: const Color(0xFFD64545),
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (shouldExit == true && mounted) {
      // QuizNavigationHost owns the play route. Pop only that navigator so
      // the user returns to ExamDetailScreen instead of leaving the app shell.
      Navigator.of(context).pop();
    }
  }

  Future<void> _showSubmitConfirmation() async {
    if (_isShowingSubmit || !mounted) return;
    _isShowingSubmit = true;
    final answeredCount = _quiz.answers
        .where((answer) => answer != null)
        .length;
    final shouldSubmit = await SubmitConfirmDialog.show(
      context,
      subjectName: _quiz.subjectById(_exam.subjectId)?.name ?? 'bài thi',
      answeredCount: answeredCount,
      unansweredCount: _questionCount - answeredCount,
      remainingTime: widget.isTimed
          ? _formatTime(_remainingSeconds)
          : 'Không tính giờ',
    );
    _isShowingSubmit = false;
    if (shouldSubmit == true && mounted) _submitQuiz();
  }

  void _submitQuiz() {
    _timer?.cancel();
    final result = _quiz.submitQuiz();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/quiz/result'),
        builder: (_) => QuizResultScreen(result: result),
      ),
    );
  }

  void _onPrimaryAction() {
    if (widget.isTimed) {
      if (_isLastQuestion) {
        _showSubmitConfirmation();
      } else {
        _quiz.nextQuestion();
        setState(() {});
      }
      return;
    }
    if (!_quiz.currentQuestionChecked) {
      if (_isLastQuestion && _quiz.selectedAnswer == null) {
        _showSubmitConfirmation();
        return;
      }
      if (_quiz.selectedAnswer == null) return;
      _quiz.checkCurrentAnswer();
      setState(() {});
      return;
    }
    if (_isLastQuestion) {
      _showSubmitConfirmation();
    } else {
      _quiz.nextQuestion();
      setState(() {});
    }
  }

  void _skipQuestion() {
    if (_isLastQuestion) {
      _showSubmitConfirmation();
      return;
    }
    _quiz.nextQuestion();
    setState(() {});
  }

  String get _timerLabel => _formatTime(_remainingSeconds);

  @override
  Widget build(BuildContext context) {
    final subject = _quiz.subjectById(_exam.subjectId);
    final selectedAnswer = _quiz.selectedAnswer;
    final isChecked = !widget.isTimed && _quiz.currentQuestionChecked;
    final progress = (_currentIndex + 1) / _questionCount;
    final buttonLabel = widget.isTimed
        ? (_isLastQuestion ? 'Nộp bài' : 'Câu tiếp')
        : isChecked
        ? (_isLastQuestion ? 'Nộp bài' : 'Câu tiếp')
        : (_isLastQuestion && selectedAnswer == null ? 'Nộp bài' : 'Kiểm tra');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exitQuiz();
      },
      child: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AuthColors.navyTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AuthColors.navy,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (subject?.name ?? 'Môn học').toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .5,
                              color: Color(0xFF8A6A17),
                            ),
                          ),
                          Text(
                            widget.isTimed ? 'Thi' : 'Luyện tập',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              height: 22 / 17,
                              fontWeight: FontWeight.w600,
                              color: AuthColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isTimed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AuthColors.navyTint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          _timerLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AuthColors.navy,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: _exitQuiz,
                      tooltip: 'Thoát bài làm',
                      icon: const Icon(Icons.close, color: AuthColors.navy),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _QuestionProgressCard(
                        questionIndex: _currentIndex,
                        questionCount: _questionCount,
                        subjectName: subject?.name ?? '',
                        progress: progress,
                        bookmarked: _bookmarkedQuestions.contains(
                          _currentIndex,
                        ),
                        onBookmark: () => setState(() {
                          if (!_bookmarkedQuestions.add(_currentIndex)) {
                            _bookmarkedQuestions.remove(_currentIndex);
                          }
                        }),
                      ),
                      const SizedBox(height: 15),
                      _QuestionPromptCard(question: _question),
                      const SizedBox(height: 15),
                      for (
                        var index = 0;
                        index < _question.options.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(height: 8),
                        _AnswerOption(
                          index: index,
                          text: _question.options[index],
                          selected: selectedAnswer == index,
                          checked: isChecked,
                          correct: _question.correctIndex == index,
                          onTap: () {
                            if (isChecked) return;
                            _quiz.selectAnswer(index);
                            setState(() {});
                          },
                        ),
                      ],
                      if (isChecked) ...[
                        const SizedBox(height: 12),
                        _ExplanationPanel(
                          correct: selectedAnswer == _question.correctIndex,
                          explanation: _question.explanation,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed:
                            widget.isTimed ||
                            _quiz.currentQuestionChecked ||
                            _quiz.selectedAnswer != null ||
                            _isLastQuestion
                            ? _onPrimaryAction
                            : null,
                        icon: Icon(
                          isChecked
                              ? (_isLastQuestion
                                    ? Icons.check_circle_outline
                                    : Icons.arrow_forward)
                              : (_isLastQuestion
                                    ? Icons.check_circle_outline
                                    : Icons.task_alt),
                          size: 18,
                        ),
                        label: Text(buttonLabel),
                        style: FilledButton.styleFrom(
                          backgroundColor: AuthColors.navy,
                          disabledBackgroundColor: AuthColors.navy,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (!isChecked &&
                        selectedAnswer == null &&
                        !_isLastQuestion)
                      TextButton(
                        onPressed: _skipQuestion,
                        child: const Text('Bỏ qua câu này'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }
}

class _QuestionProgressCard extends StatelessWidget {
  const _QuestionProgressCard({
    required this.questionIndex,
    required this.questionCount,
    required this.subjectName,
    required this.progress,
    required this.bookmarked,
    required this.onBookmark,
  });

  final int questionIndex;
  final int questionCount;
  final String subjectName;
  final double progress;
  final bool bookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Câu ${questionIndex + 1} / $questionCount',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A6A17),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AuthColors.navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onBookmark,
                tooltip: bookmarked ? 'Bỏ đánh dấu' : 'Đánh dấu xem lại',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                padding: EdgeInsets.zero,
                icon: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                  color: bookmarked ? AuthColors.navy : AuthColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: AuthColors.navy,
              backgroundColor: const Color(0xFFE7EAF2),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPromptCard extends StatelessWidget {
  const _QuestionPromptCard({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 14,
                color: AuthColors.navy,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${question.topic.toUpperCase()} • 1.0 ĐIỂM',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AuthColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              height: 24 / 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF242A32),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 15, color: AuthColors.muted),
              SizedBox(width: 5),
              Text(
                'Chạm để chọn 1 đáp án chính xác nhất',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AuthColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.checked,
    required this.correct,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool checked;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrectResult = checked && correct;
    final isWrongSelection = checked && selected && !correct;
    final isSelected = selected && !checked;
    final background = isCorrectResult
        ? _playGreenTint
        : isWrongSelection
        ? _playRedTint
        : isSelected
        ? AuthColors.navy
        : Colors.white;
    final border = isCorrectResult
        ? _playGreen
        : isWrongSelection
        ? const Color(0xFFFF4E68)
        : isSelected
        ? AuthColors.navy
        : Colors.transparent;
    final letterColor = isCorrectResult
        ? _playGreen
        : isWrongSelection
        ? _playRed
        : isSelected
        ? Colors.white
        : const Color(0xFF4B5563);
    final textColor = isSelected ? Colors.white : AuthColors.text;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: border, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x331F2A44), blurRadius: 4)]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrectResult
                      ? _playGreen
                      : isWrongSelection
                      ? _playRed
                      : isSelected
                      ? const Color(0xFF314169)
                      : const Color(0xFFEBEEF6),
                  shape: BoxShape.circle,
                ),
                child: isCorrectResult || isWrongSelection
                    ? Icon(
                        isCorrectResult ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 17,
                      )
                    : Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: letterColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 18 / 13,
                    color: textColor,
                  ),
                ),
              ),
              if (isCorrectResult)
                const Icon(Icons.check_circle, color: _playGreen, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplanationPanel extends StatelessWidget {
  const _ExplanationPanel({required this.correct, required this.explanation});

  final bool correct;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF101127),
        border: Border.all(color: const Color(0xFFFFD75E), width: .7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                correct ? Icons.lightbulb : Icons.tips_and_updates_outlined,
                size: 16,
                color: const Color(0xFFFFD75E),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  correct
                      ? 'Chúc mừng! Bạn đã chọn đúng!'
                      : 'Phân tích nguyên nhân chọn nhầm',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 18 / 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFD75E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22263F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Lưu ý bài thi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: Color(0xFFFFD75E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 18 / 12,
                color: Colors.white,
              ),
              children: [
                TextSpan(text: explanation),
                TextSpan(
                  text: correct
                      ? ' Hãy tiếp tục phát huy.'
                      : ' Hãy đọc kỹ khái niệm trước khi chọn đáp án.',
                  style: TextStyle(
                    color: correct
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
