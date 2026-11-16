import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/document_storage_datasource.dart';
import '../../data/local/documents_database.dart';
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

final documentsDatabaseProvider = Provider<DocumentsDatabase>((ref) {
  final database = DocumentsDatabase();
  ref.onDispose(database.close);
  return database;
});

final documentStorageDataSourceProvider = Provider<DocumentStorageDataSource>((
  ref,
) {
  return DocumentStorageDataSource(
    client: Supabase.instance.client,
    database: ref.watch(documentsDatabaseProvider),
  );
});
