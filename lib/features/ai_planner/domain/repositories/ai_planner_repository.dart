import '../../data/models/ai_models.dart';

abstract interface class AiPlannerRepository {
  List<AiChatMessage> get chat;
  List<AiRoadmapTask> get roadmapTasks;
  AiSummaryData summaryFor(String documentTitle);
  String replyFor(int index);
  String generateTest({
    required String title,
    required int questionCount,
    required int difficulty,
  });
  void toggleTask(int index);
  void addSuggestedTask();
}
