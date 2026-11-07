import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/data/models/stats_models.dart';
import 'package:flutter_application_1/features/progress/domain/usecases/stats_usecases.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class SubjectStatsScreen extends StatefulWidget {
  const SubjectStatsScreen({super.key});

  @override
  State<SubjectStatsScreen> createState() => _SubjectStatsScreenState();
}

class _SubjectStatsScreenState extends State<SubjectStatsScreen> {
  int _selectedIndex = 0;

  SubjectStudyStats get _subject =>
      StatsService.subjects[_selectedIndex.clamp(
        0,
        StatsService.subjects.length - 1,
      )];

  @override
  Widget build(BuildContext context) {
    final subject = _subject;
    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StatsPageHeader(
                      title: 'Theo môn học',
                      subtitle: '${subject.name} · ${subject.credits} tín chỉ',
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          for (
                            var index = 0;
                            index < StatsService.subjects.length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _SubjectChip(
                                subject: StatsService.subjects[index],
                                selected: index == _selectedIndex,
                                onTap: () =>
                                    setState(() => _selectedIndex = index),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SummaryCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatStudyTime(subject.minutes),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 28,
                                    height: 36 / 28,
                                    fontWeight: FontWeight.w700,
                                    color: AuthColors.navy,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AuthColors.navyTint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Tuần này',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    height: 18 / 12,
                                    color: AuthColors.navy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _SubjectMetric(
                                  label: 'Điểm quiz',
                                  value: '${subject.quizScore}%',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SubjectMetric(
                                  label: 'Flashcard',
                                  value: '${subject.flashcardCount} thẻ',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _SubjectMetric(
                                  label: 'Bài tập',
                                  value:
                                      '${subject.completedExercises}/${subject.totalExercises}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tiến độ từng chương',
                      style: AuthTextStyles.label,
                    ),
                    const SizedBox(height: 12),
                    for (
                      var index = 0;
                      index < subject.chapters.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(height: 10),
                      ProgressBarRow(
                        label: subject.chapters[index].title,
                        progress: subject.chapters[index].progress,
                        color: subject.chapters[index].progress >= 1
                            ? statsSuccess
                            : AuthColors.navy,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 98, 12),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed<void>('/exam-progress'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AuthColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      height: 22 / 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Xem lộ trình ôn thi'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.subject,
    required this.selected,
    required this.onTap,
  });

  final SubjectStudyStats subject;
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              subject.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AuthColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectMetric extends StatelessWidget {
  const _SubjectMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AuthColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 18 / 12,
              color: AuthColors.muted,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: AuthColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
