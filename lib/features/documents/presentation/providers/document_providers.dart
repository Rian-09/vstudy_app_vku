import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/document.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/usecases/document_usecases.dart';

final documentRepositoryProvider = ChangeNotifierProvider<DocumentRepository>(
  (ref) => DocumentRepository.instance,
);

final documentUseCasesProvider = Provider<DocumentUseCases>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentUseCases(DocumentRepositoryImpl(repository));
});
