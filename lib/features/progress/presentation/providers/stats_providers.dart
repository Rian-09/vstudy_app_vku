import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/stats_service.dart' as data;
import '../../domain/usecases/stats_usecases.dart';

final statsUseCasesProvider = Provider<StatsUseCases>(
  (ref) => StatsUseCases.instance,
);

final statsServiceProvider = Provider<data.StatsService>(
  (ref) => data.StatsService.instance,
);
