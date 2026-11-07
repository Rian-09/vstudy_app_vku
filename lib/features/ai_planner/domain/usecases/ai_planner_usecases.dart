import '../../data/datasources/ai_service.dart' as data;
import '../../data/models/ai_models.dart';
import '../../data/repositories/ai_planner_repository_impl.dart';
import '../repositories/ai_planner_repository.dart';

class AiPlannerUseCases {
  AiPlannerUseCases(this._repository);

  static final instance = AiPlannerUseCases(
    AiPlannerRepositoryImpl(data.AiService.instance),
  );

  final AiPlannerRepository _repository;

  List<AiChatMessage> get chat => _repository.chat;
  List<AiRoadmapTask> get roadmapTasks => _repository.roadmapTasks;
  AiSummaryData summaryFor(String documentTitle) =>
      _repository.summaryFor(documentTitle);
  String replyFor(int index) => _repository.replyFor(index);
  String generateMockTest({
    required String title,
    required int questionCount,
    required int difficulty,
  }) => _repository.generateTest(
    title: title,
    questionCount: questionCount,
    difficulty: difficulty,
  );
  void toggleTask(int index) => _repository.toggleTask(index);
  void addSuggestedTask() => _repository.addSuggestedTask();

  static const suggestions = data.AiService.suggestions;
  static const recentItems = data.AiService.recentItems;
  static const replies = data.AiService.replies;
}

typedef AiService = AiPlannerUseCases;
