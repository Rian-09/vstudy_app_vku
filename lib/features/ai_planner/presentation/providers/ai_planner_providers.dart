import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ai_service.dart' as data;
import '../../data/repositories/ai_planner_repository_impl.dart';
import '../../domain/usecases/ai_planner_usecases.dart';

final aiPlannerUseCasesProvider = Provider<AiPlannerUseCases>((ref) {
  return AiPlannerUseCases(
    AiPlannerRepositoryImpl(data.AiService.instance),
  );
});
