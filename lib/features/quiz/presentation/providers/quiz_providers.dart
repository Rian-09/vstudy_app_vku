import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quiz_service.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/quiz_usecases.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(QuizService.instance),
);

final quizUseCasesProvider = Provider<QuizUseCases>(
  (ref) => QuizUseCases(ref.watch(quizRepositoryProvider)),
);
