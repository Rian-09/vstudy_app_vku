import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/core/widgets/auth_widgets.dart';
import 'package:flutter_application_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_application_1/features/documents/data/models/document.dart';
import 'package:flutter_application_1/features/progress/data/datasources/stats_service.dart';
import 'package:flutter_application_1/features/progress/data/datasources/study_session_service.dart';
import 'package:flutter_application_1/features/quiz/data/datasources/quiz_service.dart';
import 'package:flutter_application_1/features/schedule/data/models/calendar_event.dart';
import 'package:flutter_application_1/features/schedule/presentation/providers/schedule_providers.dart';
import 'home_widgets.dart';
import 'home_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // The event form is opened on the app navigator, which can be outside
    // MainShell's nested ProviderScope. Reload when returning to Home so the
    // dashboard always reflects the latest schedule from the active source.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(scheduleControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull;
    if (user == null) {
      return AuthBackground(
        child: Center(
          child: Text(
            authState.isLoading
                ? 'Đang tải hồ sơ...'
                : authState.error?.toString() ?? 'Không tìm thấy hồ sơ người dùng.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final userName = user.fullName.trim();
    final scheduleState = ref.watch(scheduleControllerProvider);

    return AuthBackground(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            QuizService.instance,
            DocumentRepository.instance,
            StudySessionService.instance,
            StatsService.instance,
          ]),
          builder: (context, _) {
            final stats = StatsService.instance;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 47, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 17, right: 16),
                    child: GreetingHeader(
                      userName: userName,
                      avatarAsset:
                          user.avatarUrl ?? 'assets/images/home/home_avatar.png',
                      onAvatarTap: _openProfile,
                    ),
                  ),
                  const SizedBox(height: 31),
                  StudyProgressCard(
                    completedMinutes: stats.dayForDate(DateTime.now()).minutes,
                    goalMinutes: stats.dailyGoalMinutes,
                    quizAverage: stats.averageQuizScore,
                    hasGoal: stats.hasDailyGoal,
                    onQuizTap: () => stats.hasDailyGoal
                        ? _showMessage(context, 'Quiz sẽ sớm khả dụng.')
                        : Navigator.of(context).pushNamed('/goals-streak'),
                  ),
                  const SizedBox(height: 50),
                  QuickAccessList(
                    items: _quickAccessItems(),
                    onItemTap: (item) => _showMessage(context, item.title),
                  ),
                  const SizedBox(height: 21),
                  const AiSuggestionBanner(),
                  const SizedBox(height: 30),
                  WeeklyChart(
                    values: stats.weekDays
                        .map((day) => day.minutes / 60)
                        .toList(growable: false),
                    onDetailsTap: () =>
                        _showMessage(context, 'Chi tiết tuần sẽ sớm khả dụng.'),
                  ),
                  const SizedBox(height: 26),
                  UpcomingDeadlines(
                    items: _upcomingItems(scheduleState.valueOrNull ?? const []),
                    onSeeAllTap: () => _showMessage(
                      context,
                      'Danh sách đầy đủ sẽ sớm khả dụng.',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<QuickAccessItem> _quickAccessItems() {
    final quiz = QuizService.instance;
    final documents = DocumentRepository.instance;
    final items = <QuickAccessItem>[];
    final activeExam = quiz.activeExam;
    if (activeExam != null && quiz.lastResult == null) {
      final subject = quiz.subjectById(activeExam.subjectId);
      final answered = quiz.answers.where((answer) => answer != null).length;
      items.add(
        QuickAccessItem(
          category: 'Quiz',
          title: subject?.name ?? activeExam.title,
          detail:
              '${activeExam.chapterTitle} · Câu $answered/${activeExam.questions.length}',
          categoryColor: const Color(0xFFFFE062),
          categoryTextColor: const Color(0xFF340D6E),
          progressColor: const Color(0xFFF4D87F),
          progress: activeExam.questions.isEmpty
              ? 0
              : answered / activeExam.questions.length,
          illustrationAsset: 'assets/images/home/quick_quiz_illustration.png',
        ),
      );
    }
    final inProgressDocument = documents.savedOrDownloaded
        .where((document) => document.progress > 0 && document.progress < 1)
        .fold<StudyDocument?>(null, (current, document) {
          if (current == null || document.progress > current.progress) {
            return document;
          }
          return current;
        });
    if (inProgressDocument != null) {
      items.add(_documentItem(inProgressDocument));
    }
    if (items.isEmpty && QuizService.exams.isNotEmpty) {
      final exam = QuizService.exams.firstWhere(
        (candidate) => !candidate.isCompleted,
        orElse: () => QuizService.exams.first,
      );
      final subject = quiz.subjectById(exam.subjectId);
      items.add(
        QuickAccessItem(
          category: 'Quiz',
          title: subject?.name ?? exam.title,
          detail: '${exam.chapterTitle} · ${exam.questions.length} câu mới',
          categoryColor: const Color(0xFFFFE062),
          categoryTextColor: const Color(0xFF340D6E),
          progressColor: const Color(0xFFF4D87F),
          progress: 0,
          illustrationAsset: 'assets/images/home/quick_quiz_illustration.png',
        ),
      );
    }
    if (items.isEmpty && documents.documents.isNotEmpty) {
      items.add(_documentItem(documents.documents.first));
    }
    return items;
  }

  QuickAccessItem _documentItem(StudyDocument document) => QuickAccessItem(
    category: 'Tài liệu',
    title: document.title,
    detail: '${document.type} · ${document.pages} trang',
    categoryColor: const Color(0xFF8CA5E2),
    categoryTextColor: const Color(0xFF0D0223),
    progressColor: const Color(0xFF9EB3E6),
    progress: document.progress,
    illustrationAsset: 'assets/images/home/quick_document_illustration.png',
  );

  List<DeadlineItem> _upcomingItems(List<CalendarEvent> events) {
    final now = DateTime.now();
    final upcoming = events
        .where(
          (event) =>
              event.endsAt.isAfter(now) &&
              event.status != CalendarEventStatus.done,
        )
        .toList()
      ..sort((first, second) => first.startsAt.compareTo(second.startsAt));
    return upcoming.take(3).map((event) {
      final remaining = event.startsAt.difference(now);
      final hours = remaining.inHours;
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);
      final days = dateOnly.difference(today).inDays;
      final dateLabel = days == 0
          ? 'Hôm nay'
          : days == 1
          ? 'Ngày mai'
          : '${event.date.day.toString().padLeft(2, '0')}/${event.date.month.toString().padLeft(2, '0')}';
      final isDeadline = event.type == CalendarEventType.deadline;
      return DeadlineItem(
        title: event.title,
        schedule:
            '$dateLabel ${formatCalendarTime(event.startTime)} - ${formatCalendarTime(event.endTime)}',
        tag: isDeadline ? 'Deadline' : 'Lịch học',
        remaining: hours > 0 ? 'Còn ${hours}h' : 'Còn ${remaining.inMinutes}p',
        color: isDeadline
            ? const Color(0xFFFB2323)
            : const Color(0xFF1F2A44),
        tagColor: isDeadline
            ? const Color(0xFF880E0E)
            : const Color(0xFF731647),
        remainingColor: isDeadline
            ? const Color(0xFFCF0909)
            : const Color(0xB31F2A44),
      );
    }).toList(growable: false);
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed<void>('/profile');
    if (mounted) setState(() {});
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
