import '../models/stats_models.dart';
import '../../../schedule/data/datasources/calendar_service.dart';
import '../../../schedule/data/models/calendar_event.dart';
import '../../../quiz/data/datasources/quiz_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'study_session_service.dart';

class StatsService {
  StatsService._();

  static final StatsService instance = StatsService._();

  final Map<DateTime, int> _remoteMinutesByDate = {};
  final Map<DateTime, List<StudyActivity>> _remoteActivitiesByDate = {};
  final Map<String, List<double>> _remoteDocumentProgressBySubject = {};
  final Map<String, List<int>> _remoteDeadlineCountsBySubject = {};
  int _remoteOverdueDeadlineCount = 0;
  int? _remoteAverageQuizScore;
  bool _remoteLoaded = false;

  int _dailyGoalMinutes = 120;
  bool _hasDailyGoal = false;

  int get dailyGoalMinutes => _dailyGoalMinutes;
  bool get hasDailyGoal => _hasDailyGoal;

  List<StudySessionRecord> get sessionRecords =>
      StudySessionService.instance.records;

  int get todayMinutes => _studyMinutesForDate(DateTime.now());

  int get currentStreak {
    var streak = 0;
    var date = DateTime.now();
    while (_studyMinutesForDate(date) > 0) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    final dates = sessionRecords
        .map((record) => DateTime(record.startedAt.year, record.startedAt.month, record.startedAt.day))
        .toSet()
        .toList()
      ..sort();
    var best = 0;
    var current = 0;
    DateTime? previous;
    for (final date in dates) {
      if (previous != null && date.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) best = current;
      previous = date;
    }
    return best;
  }

  Future<void> setDailyGoalMinutes(int value) async {
    _dailyGoalMinutes = value.clamp(30, 240);
    _hasDailyGoal = true;
    final preferences = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await preferences.setInt('vstudy.daily_goal.$userId', _dailyGoalMinutes);
    }
  }

  Future<void> loadGoalForUser(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt('vstudy.daily_goal.$userId');
    _dailyGoalMinutes = value ?? 120;
    _hasDailyGoal = value != null;
  }

  static DateTime get weekStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  static DateTime get month {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  static int get selectedMonthDay => DateTime.now().day;
  static int get weeklyGoalMinutes => instance.dailyGoalMinutes * 7;
  static int get todayStudyMinutes => instance.todayMinutes;
  static int get goalDaysMetThisWeek =>
      instance.weekDays.where((day) => day.minutes >= instance.dailyGoalMinutes).length;
  static int get bestStreakDays => instance.bestStreak;
  static const semesterGoalHours = 160;
  static const semesterTotalHours = 128;
  static int get streakDays => instance.currentStreak;
  static int get focusSessions => instance.sessionRecords.length;

  static const semesterWeeklyHours = [
    6.1,
    7.2,
    6.4,
    8.5,
    9.3,
    8.5,
    10.8,
    11.6,
    9.7,
    14.2,
    12.2,
    13.4,
  ];

  static List<int> get weeklyFocusMinutes =>
      instance.weekDays.map((day) => day.minutes).toList(growable: false);
  static int get focusSessionCount => instance.sessionRecords.length;
  static String get focusBestDay {
    final days = instance.weekDays;
    if (days.isEmpty) return 'Chưa có dữ liệu';
    final best = days.reduce((a, b) => a.minutes >= b.minutes ? a : b);
    return _weekdayName(best.date.weekday);
  }
  static String get focusBestSession {
    final sessions = instance.sessionRecords;
    if (sessions.isEmpty) return 'Chưa có dữ liệu';
    final best = sessions.reduce((a, b) => a.durationMinutes >= b.durationMinutes ? a : b);
    return '${_formatClock(best.startedAt)} - ${_formatClock(best.endedAt)}';
  }
  static int get focusAverageMinutes {
    final records = instance.sessionRecords;
    if (records.isEmpty) return 0;
    return records.fold(0, (sum, item) => sum + item.durationMinutes) ~/ records.length;
  }

  static const flashcardsReviewedToday = 0;
  static const flashcardsMasteredToday = 0;
  static const flashcardsDueToday = 0;
  static const flashcardsReviewedThisWeek = 0;
  static const flashcardsTotal = 0;
  static const flashcardReviewMinutesByDay = <int>[];
  static const flashcardTopics = <FlashcardTopicStat>[];

  static const quizErrorCategories = [
    ReviewErrorStat(
      label: 'Chưa nắm khái niệm',
      count: 8,
      colorValue: 0xFFD64545,
    ),
    ReviewErrorStat(label: 'Sai bước tính', count: 5, colorValue: 0xFFDFA841),
    ReviewErrorStat(
      label: 'Đọc thiếu dữ kiện',
      count: 3,
      colorValue: 0xFF3B4A6B,
    ),
    ReviewErrorStat(
      label: 'Nhớ nhầm công thức',
      count: 2,
      colorValue: 0xFF9AA7C0,
    ),
  ];

  static const commonQuizMistakes = [
    StudyInsight(
      title: 'Nhầm điều kiện xác định',
      detail: 'Gặp 4 lần trong 3 bài quiz gần nhất',
    ),
    StudyInsight(
      title: 'Sai dấu khi biến đổi',
      detail: 'Gặp 3 lần · Ôn lại quy tắc chuyển vế',
    ),
    StudyInsight(
      title: 'Chưa đọc hết câu hỏi',
      detail: 'Gặp 2 lần · Kiểm tra dữ kiện trước khi chọn',
    ),
  ];

  static const examOverallProgress = .68;
  static const examDaysRemaining = 21;
  static const examWeeklyHoursGoal = 12;
  static const examWeeklyHours = 9.5;
  static const examSubjects = [
    ChapterProgress(title: 'Giải tích 1', progress: .82),
    ChapterProgress(title: 'Lập trình Java', progress: .64),
    ChapterProgress(title: 'Triết học', progress: .53),
    ChapterProgress(title: 'Mạng máy tính', progress: .38),
  ];

  static const examInsights = [
    StudyInsight(
      title: 'Bạn đang đi đúng tiến độ',
      detail: 'Hoàn thành 68% kế hoạch ôn thi.',
    ),
    StudyInsight(
      title: 'Ưu tiên Mạng máy tính',
      detail: 'Tiến độ thấp nhất trong các môn thi.',
    ),
  ];

  static const _defaultSubjects = [
    SubjectStudyStats(
      name: 'Giải tích 1',
      credits: 3,
      minutes: 344,
      quizScore: 82,
      flashcardCount: 134,
      completedExercises: 8,
      totalExercises: 10,
      chapters: [
        ChapterProgress(title: 'Chương 1', progress: 1),
        ChapterProgress(title: 'Chương 2', progress: 1),
        ChapterProgress(title: 'Chương 3', progress: .7),
        ChapterProgress(title: 'Chương 4', progress: .35),
        ChapterProgress(title: 'Chương 5', progress: 0),
      ],
    ),
    SubjectStudyStats(
      name: 'Pháp luật đại cương',
      credits: 3,
      minutes: 275,
      quizScore: 76,
      flashcardCount: 92,
      completedExercises: 7,
      totalExercises: 10,
      chapters: [
        ChapterProgress(title: 'Chương 1', progress: .8),
        ChapterProgress(title: 'Chương 2', progress: .65),
        ChapterProgress(title: 'Chương 3', progress: .45),
        ChapterProgress(title: 'Chương 4', progress: .2),
      ],
    ),
    SubjectStudyStats(
      name: 'Giải tích 2',
      credits: 3,
      minutes: 198,
      quizScore: 71,
      flashcardCount: 76,
      completedExercises: 5,
      totalExercises: 10,
      chapters: [
        ChapterProgress(title: 'Chương 1', progress: .65),
        ChapterProgress(title: 'Chương 2', progress: .4),
        ChapterProgress(title: 'Chương 3', progress: .15),
        ChapterProgress(title: 'Chương 4', progress: 0),
      ],
    ),
  ];

  List<SubjectStudyStats> get subjects {
    if (_remoteDocumentProgressBySubject.isEmpty &&
        _remoteDeadlineCountsBySubject.isEmpty) {
      return _defaultSubjects;
    }
    final subjectNames = {
      ..._remoteDocumentProgressBySubject.keys,
      ..._remoteDeadlineCountsBySubject.keys,
    };
    return subjectNames.map((name) {
      final progressValues = _remoteDocumentProgressBySubject[name] ?? const [];
      final progress = progressValues.isEmpty
          ? 0.0
          : progressValues.reduce((first, second) => first + second) /
              progressValues.length;
      final deadlineCounts = _remoteDeadlineCountsBySubject[name] ?? const [0, 0];
      return SubjectStudyStats(
        name: name,
        credits: 0,
        minutes: 0,
        quizScore: averageQuizScore,
        flashcardCount: 0,
        completedExercises: deadlineCounts[0],
        totalExercises: deadlineCounts[1],
        chapters: progressValues.isEmpty
            ? const []
            : [ChapterProgress(title: 'Tài liệu', progress: progress)],
      );
    }).toList(growable: false);
  }

  int get overdueDeadlineCount => _remoteLoaded
      ? _remoteOverdueDeadlineCount
      : CalendarService.instance.events
          .where(
            (event) =>
                event.type == CalendarEventType.deadline &&
                event.date.isBefore(DateTime.now()) &&
                event.status != CalendarEventStatus.done,
          )
          .length;

  static const semesterInsights = [
    StudyInsight(
      title: 'Tuần 10 học nhiều nhất',
      detail: '14h 20p, tăng 133% so với tuần 1',
    ),
    StudyInsight(
      title: 'Giải tích 1 chiếm nhiều giờ nhất',
      detail: '46h trong học kỳ · Xem chi tiết',
    ),
  ];

  List<StudyDayStat> get weekDays => List.generate(
    7,
    (index) => StudyDayStat(
      date: weekStart.add(Duration(days: index)),
      minutes: _studyMinutesForDate(weekStart.add(Duration(days: index))),
    ),
  );

  List<StudyDayStat> get weeklyFocusDays => List.generate(
    7,
    (index) => StudyDayStat(
      date: weekStart.add(Duration(days: index)),
      minutes: _studyMinutesForDate(weekStart.add(Duration(days: index))),
    ),
  );

  List<StudyDayStat> get flashcardReviewDays => List.generate(
    7,
    (index) => StudyDayStat(
      date: weekStart.add(Duration(days: index)),
      minutes: 0,
    ),
  );

  int get weeklyFocusTotalMinutes =>
      weekDays.fold(0, (total, day) => total + day.minutes);

  List<StudyDayStat> get monthDays => List.generate(
    DateTime(month.year, month.month + 1, 0).day,
    (index) {
    final day = index + 1;
    return StudyDayStat(
      date: DateTime(month.year, month.month, day),
      minutes: _studyMinutesForDate(DateTime(month.year, month.month, day)),
    );
    },
  );

  List<StudyDayStat> get studiedMonthDays =>
      monthDays.where((day) => day.minutes > 0).toList(growable: false);

  int get weekTotalMinutes =>
      weekDays.fold(0, (total, day) => total + day.minutes);

  int get monthTotalMinutes =>
      monthDays.fold(0, (total, day) => total + day.minutes);

  int get semesterTotalMinutes => semesterTotalHours * 60;

  int get averageQuizScore {
    if (_remoteLoaded) return _remoteAverageQuizScore ?? 0;
    final results = QuizService.recentResults;
    if (results.isEmpty) return 0;
    final average = results.fold<double>(
          0,
          (total, result) =>
              total + (result.score <= 10 ? result.score * 10 : result.score),
        ) /
        results.length;
    return (average * 10).round();
  }

  List<StudyActivity> activitiesForDate(DateTime date) {
    if (_remoteLoaded) {
      return _remoteActivitiesByDate[_dateKey(date)] ?? const [];
    }
    return CalendarService.instance.events
        .where(
          (event) =>
              _sameDate(event.date, date) &&
              event.type != CalendarEventType.deadline,
        )
        .map(
          (event) => StudyActivity(
            time: _formatTime(event.startTime.hour, event.startTime.minute),
            title: event.title,
            description: event.location.isEmpty
                ? event.subject
                : '${event.subject} · ${event.location}',
            durationMinutes: event.duration.inMinutes,
          ),
        )
        .toList(growable: false);
  }

  int _studyMinutesForDate(DateTime date) {
    final localMinutes = StudySessionService.instance.minutesForDate(date);
    final remoteMinutes = _remoteMinutesByDate[_dateKey(date)] ?? 0;
    return localMinutes + remoteMinutes;
  }

  Future<void> hydrateFromSupabase(SupabaseClient client) async {
    final deadlineRows = await client
        .from('deadlines')
        .select(
          'title, subject_name, event_type, starts_at, ends_at, location, '
          'status, due_at',
        )
        .order('starts_at');
    final attemptRows = await client
        .from('quiz_attempts')
        .select('score, completed_at, duration_seconds')
        .not('score', 'is', null);
    final documentProgressRows = await client
        .from('document_progress')
        .select('progress, documents(subject_id, subjects(name))');

    _remoteMinutesByDate.clear();
    _remoteActivitiesByDate.clear();
    _remoteDocumentProgressBySubject.clear();
    _remoteDeadlineCountsBySubject.clear();
    _remoteOverdueDeadlineCount = 0;
    for (final raw in deadlineRows as List) {
      final row = Map<String, dynamic>.from(raw);
      final subjectName = (row['subject_name'] as String?)?.trim();
      if (row['event_type'] == 'deadline') {
        final name = subjectName?.isNotEmpty == true ? subjectName! : 'Khác';
        final counts = _remoteDeadlineCountsBySubject.putIfAbsent(
          name,
          () => [0, 0],
        );
        counts[1]++;
        if (row['status'] == 'done') counts[0]++;
        final dueAt = DateTime.tryParse(row['due_at'] as String? ?? '');
        if (dueAt != null &&
            dueAt.isBefore(DateTime.now()) &&
            row['status'] != 'done') {
          _remoteOverdueDeadlineCount++;
        }
        continue;
      }
      final startsAt = DateTime.tryParse(row['starts_at'] as String? ?? '');
      final endsAt = DateTime.tryParse(row['ends_at'] as String? ?? '');
      if (startsAt == null || endsAt == null) continue;
      final date = _dateKey(startsAt);
      final duration = endsAt.difference(startsAt).inMinutes.clamp(0, 24 * 60);
      _remoteActivitiesByDate.putIfAbsent(date, () => []).add(
        StudyActivity(
          time: _formatTime(startsAt.hour, startsAt.minute),
          title: row['title'] as String? ?? 'Lịch học',
          description: [
            row['subject_name'] as String? ?? '',
            row['location'] as String? ?? '',
          ].where((value) => value.isNotEmpty).join(' · '),
          durationMinutes: duration,
        ),
      );
    }
    final scores = (attemptRows as List)
        .map((row) => (row as Map<String, dynamic>)['score'])
        .whereType<num>()
        .map((score) => score.toDouble())
        .toList();
    for (final raw in attemptRows as List) {
      final row = Map<String, dynamic>.from(raw);
      final completedAt = DateTime.tryParse(row['completed_at'] as String? ?? '');
      final duration = (row['duration_seconds'] as num?)?.toInt() ?? 0;
      if (completedAt != null && duration > 0) {
        _remoteMinutesByDate.update(
          _dateKey(completedAt.toLocal()),
          (minutes) => minutes + duration ~/ 60,
          ifAbsent: () => duration ~/ 60,
        );
      }
    }
    _remoteAverageQuizScore = scores.isEmpty
        ? null
        : scores
              .map((score) => score <= 10 ? score * 10 : score)
              .reduce((first, second) => first + second)
              .round() ~/
          scores.length;
    for (final raw in documentProgressRows as List) {
      final row = Map<String, dynamic>.from(raw);
      final document = row['documents'];
      final subject = document is Map<String, dynamic>
          ? document['subjects']
          : null;
      final subjectName = subject is Map<String, dynamic>
          ? subject['name'] as String?
          : null;
      final progress = (row['progress'] as num?)?.toDouble();
      if (subjectName == null || progress == null) continue;
      _remoteDocumentProgressBySubject
          .putIfAbsent(subjectName, () => [])
          .add(progress.clamp(0.0, 1.0));
    }
    _remoteLoaded = true;
  }

  void clearRemoteData() {
    _remoteLoaded = false;
    _remoteAverageQuizScore = null;
    _remoteMinutesByDate.clear();
    _remoteActivitiesByDate.clear();
    _remoteDocumentProgressBySubject.clear();
    _remoteDeadlineCountsBySubject.clear();
    _remoteOverdueDeadlineCount = 0;
  }

  static String _weekdayName(int weekday) => const [
        '',
        'Thứ hai',
        'Thứ ba',
        'Thứ tư',
        'Thứ năm',
        'Thứ sáu',
        'Thứ bảy',
        'Chủ nhật',
      ][weekday];

  static String _formatClock(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  DateTime _dateKey(DateTime value) => DateTime(value.year, value.month, value.day);

  String _formatTime(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  StudyDayStat dayForDate(DateTime date) {
    for (final day in weekDays) {
      if (_sameDate(day.date, date)) return day;
    }
    for (final day in monthDays) {
      if (_sameDate(day.date, date)) return day;
    }
    return StudyDayStat(date: date, minutes: 0);
  }

  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
