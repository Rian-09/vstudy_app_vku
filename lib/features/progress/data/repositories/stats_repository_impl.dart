import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_service.dart';
import '../models/stats_models.dart';

class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._dataSource);

  final StatsService _dataSource;

  @override
  int get dailyGoalMinutes => _dataSource.dailyGoalMinutes;

  @override
  void setDailyGoalMinutes(int value) => _dataSource.setDailyGoalMinutes(value);

  @override
  List<StudyDayStat> get weekDays => _dataSource.weekDays;

  @override
  List<StudyDayStat> get weeklyFocusDays => _dataSource.weeklyFocusDays;

  @override
  List<StudyDayStat> get flashcardReviewDays => _dataSource.flashcardReviewDays;

  @override
  int get weeklyFocusTotalMinutes => _dataSource.weeklyFocusTotalMinutes;

  @override
  List<StudyDayStat> get monthDays => _dataSource.monthDays;

  @override
  List<StudyDayStat> get studiedMonthDays => _dataSource.studiedMonthDays;

  @override
  int get weekTotalMinutes => _dataSource.weekTotalMinutes;

  @override
  int get monthTotalMinutes => _dataSource.monthTotalMinutes;

  @override
  int get semesterTotalMinutes => _dataSource.semesterTotalMinutes;

  @override
  List<StudyActivity> activitiesForDate(DateTime date) =>
      _dataSource.activitiesForDate(date);

  @override
  StudyDayStat dayForDate(DateTime date) => _dataSource.dayForDate(date);
}
