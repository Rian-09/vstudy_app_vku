import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/progress/data/models/stats_models.dart';
import 'package:flutter_application_1/features/progress/domain/usecases/stats_usecases.dart';
import 'package:flutter_application_1/core/theme/auth_theme.dart';
import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/progress/presentation/widgets/stats_widgets.dart';

class ErrorAnalysisScreen extends StatelessWidget {
  const ErrorAnalysisScreen({super.key});

  int get _totalErrors => StatsService.quizErrorCategories.fold(
    0,
    (total, category) => total + category.count,
  );

  void _openFlashcards(BuildContext context) {
    Navigator.of(context).pushNamed<void>('/flashcards');
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsPageHeader(
                title: 'Phân tích lỗi sai',
                subtitle: 'Nhận diện điểm cần ôn tập',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Expanded(
                    child: _ErrorMetric(label: 'Câu trả lời sai', value: '18'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _ErrorMetric(
                      label: 'Điểm quiz TB',
                      value: '${StatsService.averageQuizScore}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SummaryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nguyên nhân trả lời sai',
                      style: AuthTextStyles.label,
                    ),
                    const SizedBox(height: 12),
                    _ErrorDistribution(
                      categories: StatsService.quizErrorCategories,
                      total: _totalErrors,
                    ),
                    const SizedBox(height: 14),
                    for (
                      var index = 0;
                      index < StatsService.quizErrorCategories.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(height: 10),
                      _ErrorLegendRow(
                        category: StatsService.quizErrorCategories[index],
                        total: _totalErrors,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Lỗi thường gặp', style: AuthTextStyles.label),
              const SizedBox(height: 10),
              for (
                var index = 0;
                index < StatsService.commonQuizMistakes.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(height: 10),
                _MistakeCard(
                  index: index + 1,
                  insight: StatsService.commonQuizMistakes[index],
                ),
              ],
              const SizedBox(height: 16),
              SummaryCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Row(
                  children: [
                    const _FlashcardRouteIcon(),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Củng cố kiến thức',
                            style: AuthTextStyles.label,
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Ôn lại các thẻ flashcard cần nhớ.',
                            style: AuthTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openFlashcards(context),
                      tooltip: 'Mở thống kê flashcard',
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AuthColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _openFlashcards(context),
                  child: const Text('Xem thống kê ôn tập flashcard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorMetric extends StatelessWidget {
  const _ErrorMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AuthTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              height: 30 / 22,
              fontWeight: FontWeight.w700,
              color: AuthColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDistribution extends StatelessWidget {
  const _ErrorDistribution({required this.categories, required this.total});

  final List<ReviewErrorStat> categories;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 16,
        child: Row(
          children: [
            for (final category in categories)
              Expanded(
                flex: category.count,
                child: ColoredBox(color: Color(category.colorValue)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorLegendRow extends StatelessWidget {
  const _ErrorLegendRow({required this.category, required this.total});

  final ReviewErrorStat category;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (category.count / total * 100).round();
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Color(category.colorValue),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            category.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 18 / 12,
              color: AuthColors.text,
            ),
          ),
        ),
        Text(
          '${category.count} · $percent%',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            height: 18 / 12,
            color: AuthColors.muted,
          ),
        ),
      ],
    );
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.index, required this.insight});

  final int index;
  final StudyInsight insight;

  @override
  Widget build(BuildContext context) {
    return InsightCard(
      title: insight.title,
      detail: insight.detail,
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF6EBC4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$index',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AuthColors.navy,
          ),
        ),
      ),
    );
  }
}

class _FlashcardRouteIcon extends StatelessWidget {
  const _FlashcardRouteIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AuthColors.navyTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.style_outlined, color: AuthColors.navy, size: 20),
    );
  }
}
