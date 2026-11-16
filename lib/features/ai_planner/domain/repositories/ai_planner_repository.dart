import 'dart:typed_data';

import '../../data/models/ai_models.dart';
import '../../../../core/error/failure.dart';
import '../entities/ai_answer.dart';

abstract interface class AiPlannerRepository {
  Future<Result<AiAnswer>> ask(String question, {String? context});
  Future<Result<AiSummaryData>> summarize({
    required String title,
    String? documentId,
    String? fileName,
    String? contentType,
    Uint8List? bytes,
  });
  Future<Result<List<AiSummaryData>>> getSummaryHistory();
  List<AiChatMessage> get chat;
  List<AiRoadmapTask> get roadmapTasks;
  String replyFor(int index);
  String generateTest({
    required String title,
    required int questionCount,
    required int difficulty,
  });
  void toggleTask(int index);
  void addSuggestedTask();
}
