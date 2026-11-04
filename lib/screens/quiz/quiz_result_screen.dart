import 'package:flutter/material.dart';

import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});

  final QuizResult result;

  Exam? get _exam => QuizService.instance.examById(result.examId);

  String _durationLabel() {
    final seconds = result.durationSeconds > 0
        ? result.durationSeconds
        : result.durationMinutes * 60;
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  void _goToQuizHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == '/');
  }

  void _review(BuildContext context) {
    Navigator.of(context).pushNamed<void>('/review', arguments: result);
  }

  void _chart(BuildContext context) {
    Navigator.of(context).pushNamed<void>('/chart', arguments: result);
  }

  void _retry(BuildContext context) {
    Navigator.of(context).pushReplacementNamed<void, void>(
      '/play',
      arguments: QuizPlayArguments(examId: result.examId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exam = _exam;
    final subject = exam == null
        ? null
        : QuizService.instance.subjectById(exam.subjectId);
    final percent = result.score.round();
    final performance = percent >= 85
        ? 'Xuất sắc'
        : percent >= 70
        ? 'Khá giỏi'
        : percent >= 50
        ? 'Đạt'
        : 'Cần cố gắng';
    final questions = QuizService.instance.questionsForExam(result.examId);
    final topics = <String>[];
    for (final question in questions) {
      if (!topics.contains(question.topic)) topics.add(question.topic);
    }
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(17, 8, 17, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kết Quả Bài Thi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  height: 32 / 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 14),
                decoration: BoxDecoration(
                  color: AuthColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${subject?.name ?? 'Bài thi'}  ${exam?.chapterTitle ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFF346),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ScoreGauge(
                      percent: percent,
                      correct: result.correctCount,
                      total:
                          result.correctCount +
                          result.wrongCount +
                          result.skippedCount,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          performance,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            height: 22 / 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFF346),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/quiz/result_celebration.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      percent >= 70
                          ? 'Bạn đã vượt mức chuẩn với độ chính xác cao.'
                          : 'Hãy xem lại lời giải để củng cố kiến thức.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 17 / 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _ResultPill(label: _durationLabel())),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ResultPill(
                            label: '+ ${result.correctCount * 10} Đ',
                            highlight: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ResultMetric(
                      value: '${result.wrongCount + result.skippedCount}',
                      label: 'Câu sai',
                      color: const Color(0xFFDB4040),
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ResultMetric(
                      value: '${result.correctCount}',
                      label: 'Câu đúng',
                      color: const Color(0xFF3F7358),
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ResultMetric(
                      value: _durationLabel(),
                      label: 'Mỗi câu',
                      color: AuthColors.navy,
                      icon: Icons.timer_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x35DFA841),
                      offset: Offset(3, 5),
                      blurRadius: 9,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Phân tích kiến thức',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AuthColors.navy,
                            ),
                          ),
                        ),
                        Text(
                          exam?.chapterTitle ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFFDFA841),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (var index = 0; index < topics.length; index++) ...[
                      if (index > 0) const SizedBox(height: 12),
                      _TopicResultBar(
                        title: topics[index],
                        correct: result.topicCorrectCounts[topics[index]] ?? 0,
                        total: result.topicTotalCounts[topics[index]] ?? 0,
                        gold: index == 1,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF1D3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF8A6A0A),
                            size: 18,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gợi ý AI',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF8A6A0A),
                                  ),
                                ),
                                Text(
                                  'Ôn lại các chủ đề còn sai để tiến bộ hơn.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    height: 13 / 9,
                                    color: AuthColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () => _review(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AuthColors.navy,
                    foregroundColor: const Color(0xFFFFDF62),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Xem đáp án & Lời giải'),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _retry(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AuthColors.text,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AuthColors.navy),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Làm lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _goToQuizHome(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AuthColors.text,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AuthColors.navy),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Về trang chủ'),
                    ),
                  ),
                ],
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () => _chart(context),
                  icon: const Icon(Icons.bar_chart_outlined, size: 18),
                  label: const Text('Xem biểu đồ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({
    required this.percent,
    required this.correct,
    required this.total,
  });

  final int percent;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 142,
            height: 142,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 13,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFE7E3D8),
              color: const Color(0xFFC9A227),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  height: 38 / 32,
                  fontWeight: FontWeight.w800,
                  color: AuthColors.navy,
                ),
              ),
              Text(
                '$correct/$total câu đúng',
                style: const TextStyle(
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

class _ResultPill extends StatelessWidget {
  const _ResultPill({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: highlight ? const Color(0xFFFFF346) : Colors.white,
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              height: 22 / 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Icon(icon, size: 16, color: color),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: color.withValues(alpha: .8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicResultBar extends StatelessWidget {
  const _TopicResultBar({
    required this.title,
    required this.correct,
    required this.total,
    required this.gold,
  });

  final String title;
  final int correct;
  final int total;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : correct / total;
    final baseColor = gold ? const Color(0xFFDFA841) : AuthColors.navy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AuthColors.text,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: baseColor.withValues(alpha: .22),
            color: baseColor,
          ),
        ),
      ],
    );
  }
}
