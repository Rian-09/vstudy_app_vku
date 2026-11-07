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
  void setDailyGoalMinutes(int value) => _repository.setDailyGoalMinutes(value);
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
  static const selectedMonthDay = data.StatsService.selectedMonthDay;
  static const weeklyGoalMinutes = data.StatsService.weeklyGoalMinutes;
  static const todayStudyMinutes = data.StatsService.todayStudyMinutes;
  static const goalDaysMetThisWeek = data.StatsService.goalDaysMetThisWeek;
  static const bestStreakDays = data.StatsService.bestStreakDays;
  static const semesterGoalHours = data.StatsService.semesterGoalHours;
  static const semesterTotalHours = data.StatsService.semesterTotalHours;
  static const streakDays = data.StatsService.streakDays;
  static const averageQuizScore = data.StatsService.averageQuizScore;
  static const semesterWeeklyHours = data.StatsService.semesterWeeklyHours;
  static const focusSessionCount = data.StatsService.focusSessionCount;
  static const focusBestDay = data.StatsService.focusBestDay;
  static const focusBestSession = data.StatsService.focusBestSession;
  static const focusAverageMinutes = data.StatsService.focusAverageMinutes;
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
  static const subjects = data.StatsService.subjects;
  static const semesterInsights = data.StatsService.semesterInsights;
}

// Temporary compatibility alias while legacy presentation files are migrated.
typedef StatsService = StatsUseCases;
