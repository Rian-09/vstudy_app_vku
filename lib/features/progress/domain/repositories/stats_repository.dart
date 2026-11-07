import '../../data/models/stats_models.dart';

abstract interface class StatsRepository {
  int get dailyGoalMinutes;
  void setDailyGoalMinutes(int value);
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
