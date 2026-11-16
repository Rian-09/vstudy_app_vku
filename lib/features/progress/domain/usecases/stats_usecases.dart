import '../../data/datasources/stats_service.dart' as data;
import '../../data/models/stats_models.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../repositories/stats_repository.dart';

class StatsUseCases {
  StatsUseCases(this._repository);

  static final instance = StatsUseCases(
    StatsRepositoryImpl(data.StatsService.instance),
  );

  final StatsRepository _repository;

  int get dailyGoalMinutes => _repository.dailyGoalMinutes;
  Future<void> setDailyGoalMinutes(int value) => _repository.setDailyGoalMinutes(value);
  bool get hasDailyGoal => _repository.hasDailyGoal;
  List<StudyDayStat> get weekDays => _repository.weekDays;
  List<StudyDayStat> get weeklyFocusDays => _repository.weeklyFocusDays;
  List<StudyDayStat> get flashcardReviewDays => _repository.flashcardReviewDays;
  int get weeklyFocusTotalMinutes => _repository.weeklyFocusTotalMinutes;
  List<StudyDayStat> get monthDays => _repository.monthDays;
  List<StudyDayStat> get studiedMonthDays => _repository.studiedMonthDays;
  int get weekTotalMinutes => _repository.weekTotalMinutes;
  int get monthTotalMinutes => _repository.monthTotalMinutes;
  int get semesterTotalMinutes => _repository.semesterTotalMinutes;
  List<StudyActivity> activitiesForDate(DateTime date) =>
      _repository.activitiesForDate(date);
  StudyDayStat dayForDate(DateTime date) => _repository.dayForDate(date);

  static DateTime get weekStart => data.StatsService.weekStart;
  static DateTime get month => data.StatsService.month;
  static int get selectedMonthDay => data.StatsService.selectedMonthDay;
  static int get weeklyGoalMinutes => data.StatsService.weeklyGoalMinutes;
  static int get todayStudyMinutes => data.StatsService.todayStudyMinutes;
  static int get goalDaysMetThisWeek => data.StatsService.goalDaysMetThisWeek;
  static int get bestStreakDays => data.StatsService.bestStreakDays;
  static const semesterGoalHours = data.StatsService.semesterGoalHours;
  static const semesterTotalHours = data.StatsService.semesterTotalHours;
  static int get streakDays => data.StatsService.streakDays;
  static int get averageQuizScore => data.StatsService.instance.averageQuizScore;
  static const semesterWeeklyHours = data.StatsService.semesterWeeklyHours;
  static int get focusSessionCount => data.StatsService.focusSessionCount;
  static String get focusBestDay => data.StatsService.focusBestDay;
  static String get focusBestSession => data.StatsService.focusBestSession;
  static int get focusAverageMinutes => data.StatsService.focusAverageMinutes;
  static const flashcardsReviewedToday = data.StatsService.flashcardsReviewedToday;
  static const flashcardsMasteredToday = data.StatsService.flashcardsMasteredToday;
  static const flashcardsDueToday = data.StatsService.flashcardsDueToday;
  static const flashcardsReviewedThisWeek = data.StatsService.flashcardsReviewedThisWeek;
  static const flashcardTopics = data.StatsService.flashcardTopics;
  static const quizErrorCategories = data.StatsService.quizErrorCategories;
  static const commonQuizMistakes = data.StatsService.commonQuizMistakes;
  static const examOverallProgress = data.StatsService.examOverallProgress;
  static const examDaysRemaining = data.StatsService.examDaysRemaining;
  static const examWeeklyHoursGoal = data.StatsService.examWeeklyHoursGoal;
  static const examWeeklyHours = data.StatsService.examWeeklyHours;
  static const examSubjects = data.StatsService.examSubjects;
  static const examInsights = data.StatsService.examInsights;
  static List<SubjectStudyStats> get subjects => data.StatsService.instance.subjects;
  static int get overdueDeadlineCount =>
      data.StatsService.instance.overdueDeadlineCount;
  static const semesterInsights = data.StatsService.semesterInsights;
}

// Temporary compatibility alias while legacy presentation files are migrated.
typedef StatsService = StatsUseCases;
