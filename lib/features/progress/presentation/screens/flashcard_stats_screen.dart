import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/data/models/stats_models.dart';
import 'package:flutter_application_1/features/progress/domain/usecases/stats_usecases.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class FlashcardStatsScreen extends StatefulWidget {
  const FlashcardStatsScreen({super.key});

  @override
  State<FlashcardStatsScreen> createState() => _FlashcardStatsScreenState();
}

class _FlashcardStatsScreenState extends State<FlashcardStatsScreen> {
  DateTime? _selectedDate = DateTime(2026, 10, 17);

  @override
  Widget build(BuildContext context) {
    final service = StatsService.instance;
    final reviewDays = service.flashcardReviewDays;
    final selectedDay = reviewDays.firstWhere(
      (day) => _sameDate(day.date, _selectedDate),
      orElse: () => reviewDays.last,
    );
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsPageHeader(
                title: 'Ôn tập flashcard',
                subtitle: 'Theo dõi tiến độ ghi nhớ',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${StatsService.flashcardsReviewedToday}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              height: 36 / 28,
                              fontWeight: FontWeight.w700,
                              color: AuthColors.navy,
                            ),
                          ),
                        ),
                        const _FlashcardPill(label: 'Hôm nay'),
                      ],
                    ),
                    const Text('Thẻ đã ôn tập', style: AuthTextStyles.caption),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(
                          child: _FlashcardMetric(
                            label: 'Đã nhớ',
                            value: '${StatsService.flashcardsMasteredToday}',
                            color: statsSuccess,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _FlashcardMetric(
                            label: 'Cần ôn lại',
                            value: '${StatsService.flashcardsDueToday}',
                            color: statsDanger,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _FlashcardMetric(
                            label: 'Trong tuần',
                            value: '${StatsService.flashcardsReviewedThisWeek}',
                            color: AuthColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Thẻ ôn tập theo ngày',
                      style: AuthTextStyles.label,
                    ),
                    const SizedBox(height: 12),
                    StatBarChart(
                      days: reviewDays,
                      selectedDate: _selectedDate,
                      onDayTap: (date) => setState(() => _selectedDate = date),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${weekdayLabel(selectedDay.date)} · ${selectedDay.minutes} phút ôn tập',
                      textAlign: TextAlign.center,
                      style: AuthTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tiến độ theo bộ thẻ', style: AuthTextStyles.label),
              const SizedBox(height: 12),
              for (
                var index = 0;
                index < StatsService.flashcardTopics.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: 14),
                _FlashcardTopicRow(topic: StatsService.flashcardTopics[index]),
              ],
              const SizedBox(height: 16),
              InsightCard(
                title:
                    'Bạn đã nhớ ${StatsService.flashcardsMasteredToday}/'
                    '${StatsService.flashcardsReviewedToday} thẻ hôm nay',
                detail: 'Tiếp tục ôn lại các thẻ cần ghi nhớ.',
                leading: const _FlashcardIcon(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlashcardPill extends StatelessWidget {
  const _FlashcardPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AuthColors.navyTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          height: 18 / 12,
          color: AuthColors.navy,
        ),
      ),
    );
  }
}

class _FlashcardMetric extends StatelessWidget {
  const _FlashcardMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.all(9),
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
              fontSize: 11,
              height: 15 / 11,
              color: AuthColors.muted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              height: 26 / 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardTopicRow extends StatelessWidget {
  const _FlashcardTopicRow({required this.topic});

  final FlashcardTopicStat topic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(topic.title, style: AuthTextStyles.label)),
            Text(topic.detail, style: AuthTextStyles.caption),
          ],
        ),
        const SizedBox(height: 7),
        ProgressBarRow(label: '', progress: topic.progress),
      ],
    );
  }
}

class _FlashcardIcon extends StatelessWidget {
  const _FlashcardIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AuthColors.navyTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.style_outlined, color: AuthColors.navy, size: 20),
    );
  }
}

bool _sameDate(DateTime first, DateTime? second) =>
    second != null &&
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;
