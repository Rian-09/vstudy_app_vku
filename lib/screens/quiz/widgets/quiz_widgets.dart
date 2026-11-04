import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/quiz_models.dart';
import '../../../theme/auth_theme.dart';

const _quizNavy = Color(0xFF1F2A44);
const _quizGold = Color(0xFFFFDF62);
const _quizDark = Color(0xFF182033);

class QuizProgressCard extends StatelessWidget {
  const QuizProgressCard({
    super.key,
    required this.percent,
    required this.completedLessons,
    required this.totalLessons,
  });

  final int percent;
  final int completedLessons;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final progress = (percent / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 19, 18, 14),
      decoration: BoxDecoration(
        color: _quizNavy,
        borderRadius: BorderRadius.circular(38),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38DFA841),
            offset: Offset(4, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 104,
                height: 104,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 94,
                      height: 94,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 13,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white,
                        color: _quizGold,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _quizGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Hôm nay',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _quizGold,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/quiz/quiz_sparkle.svg',
                          width: 28,
                          height: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hoàn thành $completedLessons/$totalLessons bài học',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 18 / 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tăng tốc làm bài nào!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: _quizGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFD9D9D9),
              color: const Color(0xFFDFA841),
            ),
          ),
          const SizedBox(height: 14),
          const StreakDots(activeCount: 3),
        ],
      ),
    );
  }
}

class StreakDots extends StatelessWidget {
  const StreakDots({super.key, this.activeCount = 3, this.count = 5});

  final int activeCount;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < count; index++) ...[
          if (index > 0) ...[
            Expanded(
              child: Container(
                height: 2,
                color: index <= activeCount ? Colors.white : Colors.white54,
              ),
            ),
          ],
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: index < activeCount ? _quizGold : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _quizGold, width: 2),
              boxShadow: index < activeCount
                  ? const [BoxShadow(color: Color(0x99FFDF62), blurRadius: 5)]
                  : null,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SubjectTile extends StatelessWidget {
  const SubjectTile({super.key, required this.subject, required this.onTap});

  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressColor = switch (subject.id) {
      'law' => const Color(0xFF311DA5),
      'philosophy' => const Color(0xFFFFDF62),
      _ => const Color(0xFF3E9B6A),
    };
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 106,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            subject.imageAsset,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset(
                          'assets/images/quiz/quiz_star.svg',
                          width: 13,
                          height: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          subject.rating.toString(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: AuthColors.text,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF30394D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${subject.questionCount} câu  •  ${subject.examCount} đề',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        height: 14 / 10,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 4,
                    backgroundColor: progressColor.withValues(alpha: .25),
                    color: progressColor,
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

class ExamTile extends StatelessWidget {
  const ExamTile({super.key, required this.exam, required this.onTap});

  final Exam exam;
  final VoidCallback onTap;

  Color get _difficultyColor => switch (exam.difficulty) {
    >= 100 => const Color(0xFFE11D48),
    >= 75 => const Color(0xFFD97706),
    _ => const Color(0xFF059669),
  };

  Color get _difficultyBackground => switch (exam.difficulty) {
    >= 100 => const Color(0xFFFFE4E6),
    >= 75 => const Color(0xFFFEF3C7),
    _ => const Color(0xFFD1FAE5),
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        height: 19 / 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _difficultyBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${exam.difficulty}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _difficultyColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${exam.questionCount} câu • ${exam.durationMinutes} phút',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (exam.score != null)
                Text(
                  exam.score!.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _scoreColor(exam.score!),
                  ),
                )
              else
                const Text(
                  'Chưa làm xong',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WrongQuestionTile extends StatelessWidget {
  const WrongQuestionTile({super.key, required this.question});

  final Question question;

  String _letter(int index) => String.fromCharCode(65 + index);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = question.previousAnswerIndex;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.topic,
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
              Text(
                'Sai ${question.wrongCount} lần',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE11D48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 17 / 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          if (selectedIndex != null) ...[
            const SizedBox(height: 9),
            _AnswerStrip(
              label: 'BẠN ĐÃ CHỌN',
              text:
                  '${_letter(selectedIndex)}. ${question.options[selectedIndex]}',
              color: const Color(0xFFE11D48),
              background: const Color(0xFFFFF1F2),
              crossed: true,
            ),
          ],
          const SizedBox(height: 6),
          _AnswerStrip(
            label: 'ĐÁP ÁN CHÍNH XÁC',
            text:
                '${_letter(question.correctIndex)}. ${question.options[question.correctIndex]}',
            color: const Color(0xFF059669),
            background: const Color(0xFFECFDF5),
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 16 / 11,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerStrip extends StatelessWidget {
  const _AnswerStrip({
    required this.label,
    required this.text,
    required this.color,
    required this.background,
    this.crossed = false,
  });

  final String label;
  final String text;
  final Color color;
  final Color background;
  final bool crossed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              height: 15 / 10,
              color: const Color(0xFF334155),
              decoration: crossed ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class ExamInfoCard extends StatelessWidget {
  const ExamInfoCard({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _quizDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26182033),
            offset: Offset(0, 8),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              subject.id == 'philosophy'
                  ? 'assets/images/quiz/subject_header.png'
                  : subject.imageAsset,
              width: 79,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    height: 22 / 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${subject.questionCount} câu • ${subject.examCount} bài',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 16 / 11,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: subject.progress,
                          minHeight: 6,
                          color: const Color(0xFFFBBF24),
                          backgroundColor: const Color(0xCC334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    for (var index = 0; index < 3; index++)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: SvgPicture.asset(
                          'assets/images/quiz/quiz_star.svg',
                          width: 12,
                          height: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _scoreColor(double score) {
  if (score >= 8) return const Color(0xFF10B981);
  if (score >= 6.5) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}
