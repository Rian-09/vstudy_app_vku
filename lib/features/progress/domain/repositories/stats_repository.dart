import '../../data/models/stats_models.dart';

abstract interface class StatsRepository {
  int get dailyGoalMinutes;
  Future<void> setDailyGoalMinutes(int value);
  bool get hasDailyGoal;
  List<StudyDayStat> get weekDays;
  List<StudyDayStat> get weeklyFocusDays;
  List<StudyDayStat> get flashcardReviewDays;
  int get weeklyFocusTotalMinutes;
  List<StudyDayStat> get monthDays;
  List<StudyDayStat> get studiedMonthDays;
  int get weekTotalMinutes;
  int get monthTotalMinutes;
  int get semesterTotalMinutes;
  List<StudyActivity> activitiesForDate(DateTime date);
  StudyDayStat dayForDate(DateTime date);
}
