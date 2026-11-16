import 'dart:typed_data';

import '../../../../core/error/failure.dart';
import '../../data/datasources/ai_service.dart' as data;
import '../../data/models/ai_models.dart';
import '../../data/repositories/ai_planner_repository_impl.dart';
import '../entities/ai_answer.dart';
import '../repositories/ai_planner_repository.dart';

class AskAiUseCase {
  const AskAiUseCase(this._repository);

  final AiPlannerRepository _repository;

  Future<Result<AiAnswer>> call(String question, {String? context}) {
    return _repository.ask(question, context: context);
  }
}

class AiSummaryUseCase {
  const AiSummaryUseCase(this._repository);

  final AiPlannerRepository _repository;

  Future<Result<AiSummaryData>> call({
    required String title,
    String? documentId,
    String? fileName,
    String? contentType,
    Uint8List? bytes,
  }) => _repository.summarize(
    title: title,
    documentId: documentId,
    fileName: fileName,
    contentType: contentType,
    bytes: bytes,
  );
}

class AiSummaryHistoryUseCase {
  const AiSummaryHistoryUseCase(this._repository);

  final AiPlannerRepository _repository;

  Future<Result<List<AiSummaryData>>> call() => _repository.getSummaryHistory();
}

class AiPlannerUseCases {
  AiPlannerUseCases(this._repository);

  static final instance = AiPlannerUseCases(
    AiPlannerRepositoryImpl(data.AiService.instance),
  );

  final AiPlannerRepository _repository;

  List<AiChatMessage> get chat => _repository.chat;
  List<AiRoadmapTask> get roadmapTasks => _repository.roadmapTasks;
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
