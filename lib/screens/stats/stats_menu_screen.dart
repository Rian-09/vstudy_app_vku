import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/auth_theme.dart';
import '../../widgets/auth_widgets.dart';
import 'day_detail_screen.dart';
import 'error_analysis_screen.dart';
import 'exam_progress_screen.dart';
import 'flashcard_stats_screen.dart';
import 'goals_streak_screen.dart';
import 'study_stats_screen.dart';
import 'subject_stats_screen.dart';
import 'weekly_report_screen.dart';

class StatsNavigationHost extends StatelessWidget {
  const StatsNavigationHost({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/' => const StatsMenuScreen(),
          '/study' => const StudyStatsScreen(),
          '/subject' => const SubjectStatsScreen(),
          '/goals-streak' => const GoalsStreakScreen(),
          '/weekly-report' => const WeeklyReportScreen(),
          '/flashcards' => const FlashcardStatsScreen(),
          '/error-analysis' => const ErrorAnalysisScreen(),
          '/exam-progress' => const ExamProgressScreen(),
          '/day-detail' => DayDetailScreen(
            date: settings.arguments as DateTime? ?? DateTime(2026, 10, 14),
          ),
          '/placeholder' => StatsPlaceholderScreen(
            title: settings.arguments as String? ?? 'Đang phát triển',
          ),
          _ => const StatsMenuScreen(),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => page,
        );
      },
    );
  }
}

class StatsMenuScreen extends StatelessWidget {
  const StatsMenuScreen({super.key});

  static const _items = [
    _StatsMenuItem(
      title: 'Thống kê học tập',
      subtitle: 'Tiến độ theo tháng và học kỳ',
      icon: 'assets/images/stats/stats_study.svg',
      destination: '/study',
      featured: true,
    ),
    _StatsMenuItem(
      title: 'Thống kê tập trung',
      subtitle: 'Thời gian và các phiên tập trung',
      icon: 'assets/images/stats/stats_focus.svg',
      destination: '/weekly-report',
    ),
    _StatsMenuItem(
      title: 'Thống kê quiz',
      subtitle: 'Kết quả và mức độ nắm vững',
      icon: 'assets/images/stats/stats_quiz.svg',
      destination: '/error-analysis',
    ),
    _StatsMenuItem(
      title: 'Theo môn học',
      subtitle: 'Theo dõi tiến bộ từng môn',
      icon: 'assets/images/stats/stats_subjects.svg',
      destination: '/subject',
    ),
    _StatsMenuItem(
      title: 'Mục tiêu và chuỗi học',
      subtitle: 'Mục tiêu và thói quen mỗi ngày',
      icon: 'assets/images/stats/stats_streak.svg',
      destination: '/goals-streak',
    ),
  ];

  Future<void> _open(BuildContext context, _StatsMenuItem item) async {
    await Navigator.of(context).pushNamed<void>(
      item.destination,
      arguments: item.destination == '/placeholder' ? item.title : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(19, 26, 19, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thống kê',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.w700,
                  color: AuthColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hiểu hành trình học, tiến bộ mỗi ngày.',
                style: AuthTextStyles.body,
              ),
              const SizedBox(height: 24),
              for (var index = 0; index < _items.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                _StatsMenuCard(
                  item: _items[index],
                  onTap: () => _open(context, _items[index]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsMenuCard extends StatelessWidget {
  const _StatsMenuCard({required this.item, required this.onTap});

  final _StatsMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final featured = item.featured;
    return Material(
      color: featured ? AuthColors.navy : const Color(0xCCFFFFFF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: featured ? AuthColors.navy : const Color(0xE6FFFFFF),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: featured
                      ? AuthColors.navySecondary
                      : const Color(0xFFF6EBC4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(item.icon, width: 24, height: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        height: 22 / 15,
                        fontWeight: FontWeight.w600,
                        color: featured ? Colors.white : AuthColors.navy,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 18 / 12,
                        color: featured
                            ? const Color(0xFFC8CFDF)
                            : AuthColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/images/stats/stats_chevron_right.svg',
                width: 18,
                height: 18,
                colorFilter: featured
                    ? const ColorFilter.mode(Color(0xFFE1B70F), BlendMode.srcIn)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsPlaceholderScreen extends StatelessWidget {
  const StatsPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Quay lại',
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(child: Text(title, style: AuthTextStyles.label)),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Nội dung sẽ có trong phần tiếp theo.',
                    style: AuthTextStyles.body,
                    textAlign: TextAlign.center,
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

class _StatsMenuItem {
  const _StatsMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.destination,
    this.featured = false,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String destination;
  final bool featured;
}
