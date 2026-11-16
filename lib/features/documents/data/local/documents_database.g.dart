// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_database.dart';

// ignore_for_file: type=lint
class $CachedDocumentsTable extends CachedDocuments
    with TableInfo<$CachedDocumentsTable, CachedDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagesMeta = const VerificationMeta('pages');
  @override
  late final GeneratedColumn<int> pages = GeneratedColumn<int>(
    'pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<String> thumbnail = GeneratedColumn<String>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadsMeta = const VerificationMeta(
    'downloads',
  );
  @override
  late final GeneratedColumn<int> downloads = GeneratedColumn<int>(
    'downloads',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSavedMeta = const VerificationMeta(
    'isSaved',
  );
  @override
  late final GeneratedColumn<bool> isSaved = GeneratedColumn<bool>(
    'is_saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    filePath,
    bytes,
    downloadedAt,
    title,
    subject,
    author,
    type,
    size,
    pages,
    thumbnail,
    category,
    downloads,
    updatedAt,
    isSaved,
    progress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDocument> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('pages')) {
      context.handle(
        _pagesMeta,
        pages.isAcceptableOrUnknown(data['pages']!, _pagesMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('downloads')) {
      context.handle(
        _downloadsMeta,
        downloads.isAcceptableOrUnknown(data['downloads']!, _downloadsMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_saved')) {
      context.handle(
        _isSavedMeta,
        isSaved.isAcceptableOrUnknown(data['is_saved']!, _isSavedMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      pages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages'],
      ),
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      downloads: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloads'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      isSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_saved'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
    );
  }

  @override
  $CachedDocumentsTable createAlias(String alias) {
    return $CachedDocumentsTable(attachedDatabase, alias);
  }
}

class CachedDocument extends DataClass implements Insertable<CachedDocument> {
  final String id;
  final String filePath;
  final Uint8List bytes;
  final DateTime downloadedAt;
  final String? title;
  final String? subject;
  final String? author;
  final String? type;
  final String? size;
  final int? pages;
  final String? thumbnail;
  final String? category;
  final int? downloads;
  final String? updatedAt;
  final bool isSaved;
  final double progress;
  const CachedDocument({
    required this.id,
    required this.filePath,
    required this.bytes,
    required this.downloadedAt,
    this.title,
    this.subject,
    this.author,
    this.type,
    this.size,
    this.pages,
    this.thumbnail,
    this.category,
    this.downloads,
    this.updatedAt,
    required this.isSaved,
    required this.progress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_path'] = Variable<String>(filePath);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || pages != null) {
      map['pages'] = Variable<int>(pages);
    }
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<String>(thumbnail);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || downloads != null) {
      map['downloads'] = Variable<int>(downloads);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    map['is_saved'] = Variable<bool>(isSaved);
    map['progress'] = Variable<double>(progress);
    return map;
  }

  CachedDocumentsCompanion toCompanion(bool nullToAbsent) {
    return CachedDocumentsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      bytes: Value(bytes),
      downloadedAt: Value(downloadedAt),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      pages: pages == null && nullToAbsent
          ? const Value.absent()
          : Value(pages),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      downloads: downloads == null && nullToAbsent
          ? const Value.absent()
          : Value(downloads),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isSaved: Value(isSaved),
      progress: Value(progress),
    );
  }

  factory CachedDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDocument(
      id: serializer.fromJson<String>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      title: serializer.fromJson<String?>(json['title']),
      subject: serializer.fromJson<String?>(json['subject']),
      author: serializer.fromJson<String?>(json['author']),
      type: serializer.fromJson<String?>(json['type']),
      size: serializer.fromJson<String?>(json['size']),
      pages: serializer.fromJson<int?>(json['pages']),
      thumbnail: serializer.fromJson<String?>(json['thumbnail']),
      category: serializer.fromJson<String?>(json['category']),
      downloads: serializer.fromJson<int?>(json['downloads']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      isSaved: serializer.fromJson<bool>(json['isSaved']),
      progress: serializer.fromJson<double>(json['progress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filePath': serializer.toJson<String>(filePath),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'title': serializer.toJson<String?>(title),
      'subject': serializer.toJson<String?>(subject),
      'author': serializer.toJson<String?>(author),
      'type': serializer.toJson<String?>(type),
      'size': serializer.toJson<String?>(size),
      'pages': serializer.toJson<int?>(pages),
      'thumbnail': serializer.toJson<String?>(thumbnail),
      'category': serializer.toJson<String?>(category),
      'downloads': serializer.toJson<int?>(downloads),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'isSaved': serializer.toJson<bool>(isSaved),
      'progress': serializer.toJson<double>(progress),
    };
  }

  CachedDocument copyWith({
    String? id,
    String? filePath,
    Uint8List? bytes,
    DateTime? downloadedAt,
    Value<String?> title = const Value.absent(),
    Value<String?> subject = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<String?> size = const Value.absent(),
    Value<int?> pages = const Value.absent(),
    Value<String?> thumbnail = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<int?> downloads = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    bool? isSaved,
    double? progress,
  }) => CachedDocument(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    bytes: bytes ?? this.bytes,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    title: title.present ? title.value : this.title,
    subject: subject.present ? subject.value : this.subject,
    author: author.present ? author.value : this.author,
    type: type.present ? type.value : this.type,
    size: size.present ? size.value : this.size,
    pages: pages.present ? pages.value : this.pages,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    category: category.present ? category.value : this.category,
    downloads: downloads.present ? downloads.value : this.downloads,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isSaved: isSaved ?? this.isSaved,
    progress: progress ?? this.progress,
  );
  CachedDocument copyWithCompanion(CachedDocumentsCompanion data) {
    return CachedDocument(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      title: data.title.present ? data.title.value : this.title,
      subject: data.subject.present ? data.subject.value : this.subject,
      author: data.author.present ? data.author.value : this.author,
      type: data.type.present ? data.type.value : this.type,
      size: data.size.present ? data.size.value : this.size,
      pages: data.pages.present ? data.pages.value : this.pages,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      category: data.category.present ? data.category.value : this.category,
      downloads: data.downloads.present ? data.downloads.value : this.downloads,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSaved: data.isSaved.present ? data.isSaved.value : this.isSaved,
      progress: data.progress.present ? data.progress.value : this.progress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDocument(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('bytes: $bytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('title: $title, ')
          ..write('subject: $subject, ')
          ..write('author: $author, ')
          ..write('type: $type, ')
          ..write('size: $size, ')
          ..write('pages: $pages, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('category: $category, ')
          ..write('downloads: $downloads, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSaved: $isSaved, ')
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    filePath,
    $driftBlobEquality.hash(bytes),
    downloadedAt,
    title,
    subject,
    author,
    type,
    size,
    pages,
    thumbnail,
    category,
    downloads,
    updatedAt,
    isSaved,
    progress,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDocument &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.downloadedAt == this.downloadedAt &&
          other.title == this.title &&
          other.subject == this.subject &&
          other.author == this.author &&
          other.type == this.type &&
          other.size == this.size &&
          other.pages == this.pages &&
          other.thumbnail == this.thumbnail &&
          other.category == this.category &&
          other.downloads == this.downloads &&
          other.updatedAt == this.updatedAt &&
          other.isSaved == this.isSaved &&
          other.progress == this.progress);
}

class CachedDocumentsCompanion extends UpdateCompanion<CachedDocument> {
  final Value<String> id;
  final Value<String> filePath;
  final Value<Uint8List> bytes;
  final Value<DateTime> downloadedAt;
  final Value<String?> title;
  final Value<String?> subject;
  final Value<String?> author;
  final Value<String?> type;
  final Value<String?> size;
  final Value<int?> pages;
  final Value<String?> thumbnail;
  final Value<String?> category;
  final Value<int?> downloads;
  final Value<String?> updatedAt;
  final Value<bool> isSaved;
  final Value<double> progress;
  final Value<int> rowid;
  const CachedDocumentsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.bytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.subject = const Value.absent(),
    this.author = const Value.absent(),
    this.type = const Value.absent(),
    this.size = const Value.absent(),
    this.pages = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.category = const Value.absent(),
    this.downloads = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.progress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedDocumentsCompanion.insert({
    required String id,
    required String filePath,
    required Uint8List bytes,
    required DateTime downloadedAt,
    this.title = const Value.absent(),
    this.subject = const Value.absent(),
    this.author = const Value.absent(),
    this.type = const Value.absent(),
    this.size = const Value.absent(),
    this.pages = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.category = const Value.absent(),
    this.downloads = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.progress = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       filePath = Value(filePath),
       bytes = Value(bytes),
       downloadedAt = Value(downloadedAt);
  static Insertable<CachedDocument> custom({
    Expression<String>? id,
    Expression<String>? filePath,
    Expression<Uint8List>? bytes,
    Expression<DateTime>? downloadedAt,
    Expression<String>? title,
    Expression<String>? subject,
    Expression<String>? author,
    Expression<String>? type,
    Expression<String>? size,
    Expression<int>? pages,
    Expression<String>? thumbnail,
    Expression<String>? category,
    Expression<int>? downloads,
    Expression<String>? updatedAt,
    Expression<bool>? isSaved,
    Expression<double>? progress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (bytes != null) 'bytes': bytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (title != null) 'title': title,
      if (subject != null) 'subject': subject,
      if (author != null) 'author': author,
      if (type != null) 'type': type,
      if (size != null) 'size': size,
      if (pages != null) 'pages': pages,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (category != null) 'category': category,
      if (downloads != null) 'downloads': downloads,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSaved != null) 'is_saved': isSaved,
      if (progress != null) 'progress': progress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedDocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? filePath,
    Value<Uint8List>? bytes,
    Value<DateTime>? downloadedAt,
    Value<String?>? title,
    Value<String?>? subject,
    Value<String?>? author,
    Value<String?>? type,
    Value<String?>? size,
    Value<int?>? pages,
    Value<String?>? thumbnail,
    Value<String?>? category,
    Value<int?>? downloads,
    Value<String?>? updatedAt,
    Value<bool>? isSaved,
    Value<double>? progress,
    Value<int>? rowid,
  }) {
    return CachedDocumentsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      bytes: bytes ?? this.bytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      author: author ?? this.author,
      type: type ?? this.type,
      size: size ?? this.size,
      pages: pages ?? this.pages,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      downloads: downloads ?? this.downloads,
      updatedAt: updatedAt ?? this.updatedAt,
      isSaved: isSaved ?? this.isSaved,
      progress: progress ?? this.progress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (pages.present) {
      map['pages'] = Variable<int>(pages.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<String>(thumbnail.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (downloads.present) {
      map['downloads'] = Variable<int>(downloads.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (isSaved.present) {
      map['is_saved'] = Variable<bool>(isSaved.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('bytes: $bytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('title: $title, ')
          ..write('subject: $subject, ')
          ..write('author: $author, ')
          ..write('type: $type, ')
          ..write('size: $size, ')
          ..write('pages: $pages, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('category: $category, ')
          ..write('downloads: $downloads, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSaved: $isSaved, ')
          ..write('progress: $progress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DocumentsDatabase extends GeneratedDatabase {
  _$DocumentsDatabase(QueryExecutor e) : super(e);
  $DocumentsDatabaseManager get managers => $DocumentsDatabaseManager(this);
  late final $CachedDocumentsTable cachedDocuments = $CachedDocumentsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedDocuments];
}

typedef $$CachedDocumentsTableCreateCompanionBuilder =
    CachedDocumentsCompanion Function({
      required String id,
      required String filePath,
      required Uint8List bytes,
      required DateTime downloadedAt,
      Value<String?> title,
      Value<String?> subject,
      Value<String?> author,
      Value<String?> type,
      Value<String?> size,
      Value<int?> pages,
      Value<String?> thumbnail,
      Value<String?> category,
      Value<int?> downloads,
      Value<String?> updatedAt,
      Value<bool> isSaved,
      Value<double> progress,
      Value<int> rowid,
    });
typedef $$CachedDocumentsTableUpdateCompanionBuilder =
    CachedDocumentsCompanion Function({
      Value<String> id,
      Value<String> filePath,
      Value<Uint8List> bytes,
      Value<DateTime> downloadedAt,
      Value<String?> title,
      Value<String?> subject,
      Value<String?> author,
      Value<String?> type,
      Value<String?> size,
      Value<int?> pages,
      Value<String?> thumbnail,
      Value<String?> category,
      Value<int?> downloads,
      Value<String?> updatedAt,
      Value<bool> isSaved,
      Value<double> progress,
      Value<int> rowid,
    });

class $$CachedDocumentsTableFilterComposer
    extends Composer<_$DocumentsDatabase, $CachedDocumentsTable> {
  $$CachedDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloads => $composableBuilder(
    column: $table.downloads,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedDocumentsTableOrderingComposer
    extends Composer<_$DocumentsDatabase, $CachedDocumentsTable> {
  $$CachedDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloads => $composableBuilder(
    column: $table.downloads,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSaved => $composableBuilder(
    column: $table.isSaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedDocumentsTableAnnotationComposer
    extends Composer<_$DocumentsDatabase, $CachedDocumentsTable> {
  $$CachedDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get pages =>
      $composableBuilder(column: $table.pages, builder: (column) => column);

  GeneratedColumn<String> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get downloads =>
      $composableBuilder(column: $table.downloads, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSaved =>
      $composableBuilder(column: $table.isSaved, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);
}

class $$CachedDocumentsTableTableManager
    extends
        RootTableManager<
          _$DocumentsDatabase,
          $CachedDocumentsTable,
          CachedDocument,
          $$CachedDocumentsTableFilterComposer,
          $$CachedDocumentsTableOrderingComposer,
          $$CachedDocumentsTableAnnotationComposer,
          $$CachedDocumentsTableCreateCompanionBuilder,
          $$CachedDocumentsTableUpdateCompanionBuilder,
          (
            CachedDocument,
            BaseReferences<
              _$DocumentsDatabase,
              $CachedDocumentsTable,
              CachedDocument
            >,
          ),
          CachedDocument,
          PrefetchHooks Function()
        > {
  $$CachedDocumentsTableTableManager(
    _$DocumentsDatabase db,
    $CachedDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int?> downloads = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedDocumentsCompanion(
                id: id,
                filePath: filePath,
                bytes: bytes,
                downloadedAt: downloadedAt,
                title: title,
                subject: subject,
                author: author,
                type: type,
                size: size,
                pages: pages,
                thumbnail: thumbnail,
                category: category,
                downloads: downloads,
                updatedAt: updatedAt,
                isSaved: isSaved,
                progress: progress,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String filePath,
                required Uint8List bytes,
                required DateTime downloadedAt,
                Value<String?> title = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String?> thumbnail = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int?> downloads = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<bool> isSaved = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedDocumentsCompanion.insert(
                id: id,
                filePath: filePath,
                bytes: bytes,
                downloadedAt: downloadedAt,
                title: title,
                subject: subject,
                author: author,
                type: type,
                size: size,
                pages: pages,
                thumbnail: thumbnail,
                category: category,
                downloads: downloads,
                updatedAt: updatedAt,
                isSaved: isSaved,
                progress: progress,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedDocumentsTable, CachedDocument>(table),
                  BaseReferences<
                    _$DocumentsDatabase,
                    $CachedDocumentsTable,
                    CachedDocument
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$DocumentsDatabase,
      $CachedDocumentsTable,
      CachedDocument,
      $$CachedDocumentsTableFilterComposer,
      $$CachedDocumentsTableOrderingComposer,
      $$CachedDocumentsTableAnnotationComposer,
      $$CachedDocumentsTableCreateCompanionBuilder,
      $$CachedDocumentsTableUpdateCompanionBuilder,
      (
        CachedDocument,
        BaseReferences<
          _$DocumentsDatabase,
          $CachedDocumentsTable,
          CachedDocument
        >,
      ),
      CachedDocument,
      PrefetchHooks Function()
    >;

class $DocumentsDatabaseManager {
  final _$DocumentsDatabase _db;
  $DocumentsDatabaseManager(this._db);
  $$CachedDocumentsTableTableManager get cachedDocuments =>
      $$CachedDocumentsTableTableManager(_db, _db.cachedDocuments);
}
