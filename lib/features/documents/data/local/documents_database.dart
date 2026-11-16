import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/document.dart';

part 'documents_database.g.dart';

class CachedDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get filePath => text()();
  BlobColumn get bytes => blob()();
  DateTimeColumn get downloadedAt => dateTime()();
  TextColumn get title => text().nullable()();
  TextColumn get subject => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get size => text().nullable()();
  IntColumn get pages => integer().nullable()();
  TextColumn get thumbnail => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get downloads => integer().nullable()();
  TextColumn get updatedAt => text().nullable()();
  BoolColumn get isSaved => boolean().withDefault(const Constant(false))();
  RealColumn get progress => real().withDefault(const Constant(1.0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedDocuments])
class DocumentsDatabase extends _$DocumentsDatabase {
  static final instance = DocumentsDatabase();

  DocumentsDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'vstudy_documents'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(cachedDocuments, cachedDocuments.title);
        await m.addColumn(cachedDocuments, cachedDocuments.subject);
        await m.addColumn(cachedDocuments, cachedDocuments.author);
        await m.addColumn(cachedDocuments, cachedDocuments.type);
        await m.addColumn(cachedDocuments, cachedDocuments.size);
        await m.addColumn(cachedDocuments, cachedDocuments.pages);
        await m.addColumn(cachedDocuments, cachedDocuments.thumbnail);
        await m.addColumn(cachedDocuments, cachedDocuments.category);
        await m.addColumn(cachedDocuments, cachedDocuments.downloads);
        await m.addColumn(cachedDocuments, cachedDocuments.updatedAt);
        await m.addColumn(cachedDocuments, cachedDocuments.isSaved);
        await m.addColumn(cachedDocuments, cachedDocuments.progress);
      }
    },
  );

  Future<void> savePdf({
    required String id,
    required String filePath,
    required Uint8List bytes,
    StudyDocument? document,
  }) async {
    await into(cachedDocuments).insertOnConflictUpdate(
      CachedDocumentsCompanion.insert(
        id: id,
        filePath: filePath,
        bytes: bytes,
        downloadedAt: DateTime.now(),
        title: Value(document?.title),
        subject: Value(document?.subject),
        author: Value(document?.author),
        type: Value(document?.type),
        size: Value(document?.size),
        pages: Value(document?.pages),
        thumbnail: Value(document?.thumbnail),
        category: Value(document?.category.name),
        downloads: Value(document?.downloads),
        updatedAt: Value(document?.updatedAt),
        isSaved: Value(document?.isSaved ?? false),
        progress: const Value(1),
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

  Future<List<CachedDocument>> getCachedDocuments() {
    return select(cachedDocuments).get();
  }
}
