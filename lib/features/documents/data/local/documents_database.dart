import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'documents_database.g.dart';

class CachedDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get filePath => text()();
  BlobColumn get bytes => blob()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedDocuments])
class DocumentsDatabase extends _$DocumentsDatabase {
  static final instance = DocumentsDatabase();

  DocumentsDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'vstudy_documents'));

  @override
  int get schemaVersion => 1;

  Future<void> savePdf({
    required String id,
    required String filePath,
    required Uint8List bytes,
  }) async {
    await into(cachedDocuments).insertOnConflictUpdate(
      CachedDocumentsCompanion.insert(
        id: id,
        filePath: filePath,
        bytes: bytes,
        downloadedAt: DateTime.now(),
      ),
    );
  }

  Future<Uint8List?> readPdf(String id) async {
    final row = await (select(
      cachedDocuments,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row?.bytes;
  }

  Future<bool> hasPdf(String id) async {
    final row = await (select(
      cachedDocuments,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row != null;
  }

  Future<Set<String>> cachedDocumentIds() async {
    final rows = await select(cachedDocuments).get();
    return rows.map((row) => row.id).toSet();
  }
}
