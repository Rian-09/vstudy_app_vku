import '../../domain/repositories/ai_planner_repository.dart';
import '../datasources/ai_service.dart';
import '../models/ai_models.dart';

class AiPlannerRepositoryImpl implements AiPlannerRepository {
  AiPlannerRepositoryImpl(this._dataSource);

  final AiService _dataSource;

  @override
  List<AiChatMessage> get chat => _dataSource.chat;

  @override
  List<AiRoadmapTask> get roadmapTasks => _dataSource.roadmapTasks;

  @override
  AiSummaryData summaryFor(String documentTitle) =>
      _dataSource.summaryFor(documentTitle);

  @override
  String replyFor(int index) => _dataSource.replyFor(index);

  @override
  String generateTest({
    required String title,
    required int questionCount,
    required int difficulty,
  }) => _dataSource.generateMockTest(
    title: title,
    questionCount: questionCount,
    difficulty: difficulty,
  );

  @override
  void toggleTask(int index) => _dataSource.toggleTask(index);

  @override
  void addSuggestedTask() => _dataSource.addSuggestedTask();
}
