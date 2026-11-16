import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/ai_planner_repository.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/ai_answer.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/ai_answer_cache.dart';
import '../datasources/ai_service.dart';
import '../models/ai_models.dart';
import '../../domain/services/ai_offline_fallback.dart';

class AiPlannerRepositoryImpl implements AiPlannerRepository {
  AiPlannerRepositoryImpl(
    this._dataSource, {
    this._remoteDataSource,
    AiAnswerCache? cache,
    AiOfflineFallback? fallback,
  }) : _cache = cache ?? AiAnswerCache(),
       _fallback = fallback ?? const AiOfflineFallback();

  final AiService _dataSource;
  final AiRemoteDataSource? _remoteDataSource;
  final AiAnswerCache _cache;
  final AiOfflineFallback _fallback;

  @override
  Future<Result<AiAnswer>> ask(String question, {String? context}) async {
    final remote = _remoteDataSource;
    if (remote == null) return _offlineResult();
    try {
      final answer = await remote.ask(question, context: context);
      await _cache.write(answer);
      return Right(answer);
    } on Object catch (_) {
      return _offlineResult(question);
    }
  }

  Future<Result<AiAnswer>> _offlineResult([String? question]) async {
    final cached = await _cache.read();
    if (cached != null) return Right(cached);
    return Right(
      AiAnswer(
        answer: _fallback.answerFor(question ?? ''),
        model: 'offline-fallback',
      ),
    );
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
