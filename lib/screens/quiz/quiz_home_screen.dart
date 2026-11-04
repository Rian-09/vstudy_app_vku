import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'exam_detail_screen.dart';
import 'subject_quiz_screen.dart';
import 'widgets/quiz_widgets.dart';

class QuizNavigationHost extends StatelessWidget {
  const QuizNavigationHost({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/' => const QuizHomeScreen(),
          '/subject' => SubjectQuizScreen(
            subjectId: settings.arguments as String? ?? 'philosophy',
          ),
          '/exam' => ExamDetailScreen(
            examId: settings.arguments as String? ?? '',
          ),
          '/play-placeholder' => QuizPartTwoPlaceholder(
            examId: settings.arguments as String? ?? '',
          ),
          _ => const QuizHomeScreen(),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => page,
        );
      },
    );
  }
}

enum _QuizFilter { all, practice, exams, wrong }

class QuizHomeScreen extends StatefulWidget {
  const QuizHomeScreen({super.key});

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  _QuizFilter _filter = _QuizFilter.all;

  static const _filterLabels = {
    _QuizFilter.all: 'Tất cả',
    _QuizFilter.practice: 'Luyện tập',
    _QuizFilter.exams: 'Đề thi',
    _QuizFilter.wrong: 'Câu sai (2)',
  };

  void _openSubject(Subject subject) {
    Navigator.of(context).pushNamed<void>('/subject', arguments: subject.id);
  }

  void _openExam(Exam exam) {
    Navigator.of(context).pushNamed<void>('/exam', arguments: exam.id);
  }

  @override
  Widget build(BuildContext context) {
    final service = QuizService.instance;
    final subjects = service.allSubjects;
    final results = QuizService.recentResults;
    final wrongQuestions = subjects
        .expand((subject) => service.wrongQuestionsForSubject(subject.id))
        .toList(growable: false);

    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 82),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'QUIZZ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        height: 36 / 28,
                        fontWeight: FontWeight.w800,
                        color: AuthColors.navy,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/quiz/quiz_sparkle.svg',
                    width: 30,
                    height: 30,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Luyện tập mỗi ngày, nhớ lâu hơn!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const QuizProgressCard(
                percent: 60,
                completedLessons: 3,
                totalLessons: 5,
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _QuizFilter.values.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _QuizFilter.values[index];
                    final selected = _filter == filter;
                    return _QuizFilterChip(
                      label: _filterLabels[filter]!,
                      selected: selected,
                      onTap: () => setState(() => _filter = filter),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              if (_filter == _QuizFilter.all ||
                  _filter == _QuizFilter.practice) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 7, bottom: 10),
                  child: Text(
                    'Môn học',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AuthColors.navy,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subjects.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 106,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                  ),
                  itemBuilder: (context, index) => SubjectTile(
                    subject: subjects[index],
                    onTap: () => _openSubject(subjects[index]),
                  ),
                ),
              ],
              if (_filter == _QuizFilter.all ||
                  _filter == _QuizFilter.exams) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(7, 18, 7, 9),
                  child: Text(
                    'Kết quả gần đây',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF213A65),
                    ),
                  ),
                ),
                for (var index = 0; index < results.length; index++) ...[
                  if (index > 0) const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final result = results[index];
                      final exam = service.examById(result.examId);
                      if (exam == null) return const SizedBox.shrink();
                      return ExamTile(exam: exam, onTap: () => _openExam(exam));
                    },
                  ),
                ],
              ],
              if (_filter == _QuizFilter.wrong) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(7, 4, 7, 10),
                  child: Text(
                    'Câu hỏi cần ôn lại',
                    style: AuthTextStyles.label,
                  ),
                ),
                for (final question in wrongQuestions) ...[
                  WrongQuestionTile(question: question),
                  const SizedBox(height: 9),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizFilterChip extends StatelessWidget {
  const _QuizFilterChip({
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: selected ? Colors.white : AuthColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizPartTwoPlaceholder extends StatelessWidget {
  const QuizPartTwoPlaceholder({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context) {
    final exam = QuizService.instance.examById(examId);
    return AuthBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Quay lại',
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(
                    child: Text(
                      exam?.title ?? 'Làm bài',
                      style: AuthTextStyles.label,
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Text('Làm bài sẽ có trong phần tiếp theo.'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
