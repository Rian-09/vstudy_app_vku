import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/ai_answer_cache.dart';
import '../../data/datasources/ai_remote_datasource.dart';
import '../../data/datasources/ai_service.dart' as data;
import '../../data/repositories/ai_planner_repository_impl.dart';
import '../../domain/usecases/ai_planner_usecases.dart';

final aiPlannerUseCasesProvider = Provider<AiPlannerUseCases>((ref) {
  return AiPlannerUseCases(AiPlannerRepositoryImpl(data.AiService.instance));
});

final askAiUseCaseProvider = Provider<AskAiUseCase>((ref) {
  final repository = AiPlannerRepositoryImpl(
    data.AiService.instance,
    remoteDataSource: AiRemoteDataSource(Supabase.instance.client),
    cache: AiAnswerCache(),
  );
  return AskAiUseCase(repository);
});

final aiSummaryUseCaseProvider = Provider<AiSummaryUseCase>((ref) {
  final repository = AiPlannerRepositoryImpl(
    data.AiService.instance,
    remoteDataSource: AiRemoteDataSource(Supabase.instance.client),
  );
  return AiSummaryUseCase(repository);
});

final aiSummaryHistoryUseCaseProvider = Provider<AiSummaryHistoryUseCase>((
  ref,
) {
  final repository = AiPlannerRepositoryImpl(
    data.AiService.instance,
    remoteDataSource: AiRemoteDataSource(Supabase.instance.client),
  );
  return AiSummaryHistoryUseCase(repository);
});
