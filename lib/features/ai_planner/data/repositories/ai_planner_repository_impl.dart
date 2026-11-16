import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/ai_answer.dart';
import '../../domain/repositories/ai_planner_repository.dart';
import '../../domain/services/ai_offline_fallback.dart';
import '../datasources/ai_answer_cache.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/ai_service.dart';
import '../models/ai_models.dart';

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
    if (remote == null) {
      return Left(AiFailure('Dịch vụ AI chưa được cấu hình cho ứng dụng này.'));
    }
    try {
      final answer = await remote.ask(question, context: context);
      await _cache.write(answer);
      return Right(answer);
    } on SocketException catch (_) {
      return _offlineResult(question);
    } on TimeoutException catch (_) {
      return Left(AiFailure('Máy chủ AI phản hồi quá lâu. Vui lòng thử lại.'));
    } on FunctionException catch (error) {
      final details = error.details;
      final serverMessage = details is Map
          ? details['error']?.toString()
          : details?.toString();
      return Left(
        AiFailure(
          serverMessage == null || serverMessage.isEmpty
              ? 'Dịch vụ AI gặp lỗi (HTTP ${error.status}). Vui lòng thử lại sau.'
              : 'Dịch vụ AI: $serverMessage',
          code: '${error.status}',
        ),
      );
    } on Object catch (error) {
      return Left(AiFailure('Không thể gọi dịch vụ AI: ${error.toString()}'));
    }
  }

  @override
  Future<Result<AiSummaryData>> summarize({
    required String title,
    String? documentId,
    String? fileName,
    String? contentType,
    Uint8List? bytes,
  }) async {
    final remote = _remoteDataSource;
    if (remote == null) {
      return Left(AiFailure('Dịch vụ AI chưa được cấu hình cho ứng dụng này.'));
    }
    try {
      final result = await remote.summarize(
        title: title,
        documentId: documentId,
        fileName: fileName,
        contentType: contentType,
        bytes: bytes,
      );
      return Right(result);
    } on FunctionException catch (error) {
      final details = error.details;
      final serverMessage = details is Map
          ? details['error']?.toString()
          : details?.toString();
      return Left(
        AiFailure(
          serverMessage == null || serverMessage.isEmpty
              ? 'Dịch vụ AI gặp lỗi (HTTP ${error.status}). Vui lòng thử lại.'
              : serverMessage,
          code: '${error.status}',
        ),
      );
    } on SocketException {
      return const Left(
        AiFailure('Không có kết nối mạng. Hãy kiểm tra Wi-Fi và thử lại.'),
      );
    } on TimeoutException {
      return const Left(AiFailure('AI phản hồi quá lâu. Vui lòng thử lại.'));
    } on Object catch (error) {
      return Left(AiFailure('Không thể tóm tắt tài liệu: $error'));
    }
  }

  @override
  Future<Result<List<AiSummaryData>>> getSummaryHistory() async {
    final remote = _remoteDataSource;
    if (remote == null) {
      return Left(AiFailure('Dịch vụ AI chưa được cấu hình cho ứng dụng này.'));
    }
    try {
      return Right(await remote.getSummaryHistory());
    } on Object catch (error) {
      return Left(AiFailure('Không tải được lịch sử tóm tắt: $error'));
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
