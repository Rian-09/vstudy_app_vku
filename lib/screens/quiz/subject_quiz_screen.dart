import 'package:flutter/material.dart';

import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'widgets/quiz_widgets.dart';

class SubjectQuizScreen extends StatelessWidget {
  const SubjectQuizScreen({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final service = QuizService.instance;
    final subject = service.subjectById(subjectId);
    if (subject == null) {
      return AuthBackground(
        child: SafeArea(
          child: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Môn học không còn khả dụng · Quay lại'),
            ),
          ),
        ),
      );
    }
    final exams = service.examsForSubject(subject.id);
    final wrongQuestions = service.wrongQuestionsForSubject(subject.id);
    return DefaultTabController(
      length: 3,
      child: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              _SubjectHeader(subject: subject),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 13, 20, 8),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AuthColors.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF475569),
                    labelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Chung'),
                      Tab(text: 'Đề'),
                      Tab(text: 'Câu sai'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _SubjectOverviewTab(subject: subject, exams: exams),
                    _SubjectExamsTab(exams: exams),
                    _SubjectWrongTab(questions: wrongQuestions),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 63,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Quay lại',
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFDFA841),
                    size: 22,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      height: 21 / 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF192238),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Quiz',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF8A93AA),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: ExamInfoCard(subject: subject),
        ),
      ],
    );
  }
}

class _SubjectOverviewTab extends StatelessWidget {
  const _SubjectOverviewTab({required this.subject, required this.exams});

  final Subject subject;
  final List<Exam> exams;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _SubjectStatCard(
                  image: 'assets/images/quiz/exam_questions.png',
                  value: '${subject.questionCount}',
                  label: 'Câu hỏi',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SubjectStatCard(
                  image: 'assets/images/quiz/exam_duration.png',
                  value: '${subject.examCount}',
                  label: 'Bộ đề',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SubjectStatCard(
                  image: 'assets/images/quiz/exam_difficulty.png',
                  value: 'Khó',
                  label: 'Mức độ',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Tổng quan môn học', style: AuthTextStyles.label),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${exams.length} bộ đề · ${subject.questionCount} câu hỏi',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AuthColors.navy,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Luyện tập theo chương để củng cố kiến thức và chuẩn bị cho kỳ thi.',
                  style: AuthTextStyles.caption,
                ),
                const SizedBox(height: 13),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 6,
                    color: const Color(0xFFDFA841),
                    backgroundColor: const Color(0xFFF6EBC4),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Đã hoàn thành ${(subject.progress * 100).round()}% lộ trình',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: AuthColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Bộ đề nổi bật', style: AuthTextStyles.label),
          const SizedBox(height: 9),
          for (final exam in exams.take(2)) ...[
            ExamTile(
              exam: exam,
              onTap: () =>
                  Navigator.of(context)
                      .pushNamed<void>('/exam', arguments: exam.id),
            ),
            const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _SubjectExamsTab extends StatelessWidget {
  const _SubjectExamsTab({required this.exams});

  final List<Exam> exams;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(7, 8, 7, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF182033),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: exams.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => ExamTile(
          exam: exams[index],
          onTap: () =>
              Navigator.of(context)
                  .pushNamed<void>('/exam', arguments: exams[index].id),
        ),
      ),
    );
  }
}

class _SubjectWrongTab extends StatelessWidget {
  const _SubjectWrongTab({required this.questions});

  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(7, 8, 7, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF182033),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _WrongQuestionSummary(count: questions.length),
          const SizedBox(height: 14),
          for (final question in questions) ...[
            WrongQuestionTile(question: question),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _WrongQuestionSummary extends StatelessWidget {
  const _WrongQuestionSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$count câu cần ôn lại',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const Text(
                'Cần chú ý',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE11D48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Luyện tập đều đặn giúp củng cố kiến thức thi cử.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 16 / 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDFA841),
              foregroundColor: const Color(0xFF0F172A),
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Luyện lại tất cả câu sai'),
          ),
        ],
      ),
    );
  }
}

class _SubjectStatCard extends StatelessWidget {
  const _SubjectStatCard({
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
      height: 79,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AuthColors.navy, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, width: 25, height: 25, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            '$value $label',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Color(0xFF3B526B),
            ),
          ),
        ],
      ),
    );
  }
}
