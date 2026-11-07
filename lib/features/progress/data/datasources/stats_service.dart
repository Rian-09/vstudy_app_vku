import '../models/stats_models.dart';

class StatsService {
  StatsService._();

  static final StatsService instance = StatsService._();

  int _dailyGoalMinutes = 120;

  int get dailyGoalMinutes => _dailyGoalMinutes;

  void setDailyGoalMinutes(int value) {
    _dailyGoalMinutes = value.clamp(30, 240);
  }

  static final weekStart = DateTime(2026, 10, 12);
  static final month = DateTime(2026, 10);
  static const selectedMonthDay = 14;
  static const weeklyGoalMinutes = 15 * 60;
  static const todayStudyMinutes = 100;
  static const goalDaysMetThisWeek = 5;
  static const bestStreakDays = 14;
  static const semesterGoalHours = 160;
  static const semesterTotalHours = 128;
  static const streakDays = 7;
  static const averageQuizScore = 78;
  static const focusSessions = 18;

  static const _weekMinutes = [90, 120, 125, 110, 135, 150, 130];
  static const _monthMinutes = [
    245,
    185,
    210,
    140,
    180,
    180,
    60,
    180,
    180,
    245,
    0,
    180,
    180,
    125,
  ];
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

  static const weeklyFocusMinutes = [45, 60, 80, 30, 65, 75, 95];
  static const focusSessionCount = 18;
  static const focusBestDay = 'Thứ bảy';
  static const focusBestSession = '09:00 - 10:35';
  static const focusAverageMinutes = 25;

  static const flashcardsReviewedToday = 18;
  static const flashcardsMasteredToday = 14;
  static const flashcardsDueToday = 6;
  static const flashcardsReviewedThisWeek = 94;
  static const flashcardsTotal = 134;
  static const flashcardReviewMinutesByDay = [38, 42, 26, 50, 35, 44, 30];
  static const flashcardTopics = [
    FlashcardTopicStat(
      title: 'Giải tích 1',
      detail: 'Đã thuộc 34/40 thẻ',
      reviewed: 34,
      total: 40,
    ),
    FlashcardTopicStat(
      title: 'Pháp luật đại cương',
      detail: 'Đã thuộc 26/32 thẻ',
      reviewed: 26,
      total: 32,
    ),
    FlashcardTopicStat(
      title: 'Triết học',
      detail: 'Đã thuộc 18/25 thẻ',
      reviewed: 18,
      total: 25,
    ),
  ];

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

  static const subjects = [
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

  static const _activities = <int, List<StudyActivity>>{
    12: [
      StudyActivity(
        time: '09:00',
        title: 'Giải tích 1',
        description: 'Bài tập giới hạn · Hoàn thành 5 bài',
        durationMinutes: 50,
      ),
      StudyActivity(
        time: '19:30',
        title: 'Ôn flashcard',
        description: 'Giải tích 1 · Ôn 18 thẻ',
        durationMinutes: 40,
      ),
    ],
    13: [
      StudyActivity(
        time: '10:00',
        title: 'Pháp luật đại cương',
        description: 'Đọc chương 2 · Ghi chú bài học',
        durationMinutes: 60,
      ),
      StudyActivity(
        time: '20:00',
        title: 'Ôn tập bài giảng',
        description: 'Tóm tắt nội dung trong ngày',
        durationMinutes: 60,
      ),
    ],
    14: [
      StudyActivity(
        time: '08:00',
        title: 'Giải tích 1',
        description: 'Bài tập giới hạn · Hoàn thành 6 bài',
        durationMinutes: 45,
      ),
      StudyActivity(
        time: '14:00',
        title: 'Triết học',
        description: 'Đọc chương 2 · Ghi chú 4 ý chính',
        durationMinutes: 50,
      ),
      StudyActivity(
        time: '19:00',
        title: 'Ôn flashcard',
        description: 'Giải tích 1 · Ôn 20 thẻ, nhớ 17 thẻ',
        durationMinutes: 30,
      ),
    ],
  };

  List<StudyDayStat> get weekDays => List.generate(
    _weekMinutes.length,
    (index) => StudyDayStat(
      date: weekStart.add(Duration(days: index)),
      minutes: _weekMinutes[index],
    ),
  );

  List<StudyDayStat> get weeklyFocusDays => List.generate(
    weeklyFocusMinutes.length,
    (index) => StudyDayStat(
      date: weekStart.add(Duration(days: index)),
      minutes: weeklyFocusMinutes[index],
    ),
  );

  List<StudyDayStat> get flashcardReviewDays => List.generate(
    flashcardReviewMinutesByDay.length,
    (index) => StudyDayStat(
      date: weekStart.add(Duration(days: index)),
      minutes: flashcardReviewMinutesByDay[index],
    ),
  );

  int get weeklyFocusTotalMinutes =>
      weeklyFocusMinutes.fold(0, (total, minutes) => total + minutes);

  List<StudyDayStat> get monthDays => List.generate(31, (index) {
    final day = index + 1;
    return StudyDayStat(
      date: DateTime(month.year, month.month, day),
      minutes: day <= _monthMinutes.length ? _monthMinutes[day - 1] : 0,
    );
  });

  List<StudyDayStat> get studiedMonthDays =>
      monthDays.where((day) => day.minutes > 0).toList(growable: false);

  int get weekTotalMinutes =>
      weekDays.fold(0, (total, day) => total + day.minutes);

  int get monthTotalMinutes =>
      monthDays.fold(0, (total, day) => total + day.minutes);

  int get semesterTotalMinutes => semesterTotalHours * 60;

  List<StudyActivity> activitiesForDate(DateTime date) {
    if (date.year != month.year || date.month != month.month) {
      return const [];
    }
    return _activities[date.day] ?? const [];
  }

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
