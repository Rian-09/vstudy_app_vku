import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/document_storage_datasource.dart';
import '../../data/local/documents_database.dart';
import '../../data/models/document.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/usecases/document_usecases.dart';

// The repository is a process-wide service because auth hydration and the
// document screens share its local cache. A plain Provider must be used here:
// ChangeNotifierProvider owns and disposes its value when a ProviderScope is
// torn down, which would dispose this singleton and break later screens/tests.
final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepository.instance,
);

final documentUseCasesProvider = Provider<DocumentUseCases>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentUseCases(
    DocumentRepositoryImpl(
      repository,
      ref.watch(documentStorageDataSourceProvider),
    ),
  );
});

final documentsDatabaseProvider = Provider<DocumentsDatabase>((ref) {
  return DocumentsDatabase.instance;
});

final documentStorageDataSourceProvider = Provider<DocumentStorageDataSource>((
  ref,
) {
  return DocumentStorageDataSource(
    client: Supabase.instance.client,
    database: ref.watch(documentsDatabaseProvider),
  );
});
