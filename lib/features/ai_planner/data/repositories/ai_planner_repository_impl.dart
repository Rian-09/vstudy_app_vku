import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/ai_planner_repository.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/ai_answer.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/ai_service.dart';
import '../models/ai_models.dart';

class AiPlannerRepositoryImpl implements AiPlannerRepository {
  AiPlannerRepositoryImpl(this._dataSource, {this._remoteDataSource});

  final AiService _dataSource;
  final AiRemoteDataSource? _remoteDataSource;

  @override
  Future<Result<AiAnswer>> ask(String question, {String? context}) async {
    final remote = _remoteDataSource;
    if (remote == null) {
      return const Left(AiFailure('AI chưa được cấu hình.'));
    }
    try {
      return Right(await remote.ask(question, context: context));
    } on Object catch (error) {
      return Left(AiFailure('Không thể nhận phản hồi AI: $error'));
    }
  }

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
