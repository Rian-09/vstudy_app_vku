// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_database.dart';

// ignore_for_file: type=lint
class $CachedScheduleEventsTable extends CachedScheduleEvents
    with TableInfo<$CachedScheduleEventsTable, CachedScheduleEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedScheduleEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<String> reminder = GeneratedColumn<String>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checklistJsonMeta = const VerificationMeta(
    'checklistJson',
  );
  @override
  late final GeneratedColumn<String> checklistJson = GeneratedColumn<String>(
    'checklist_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subject,
    type,
    format,
    startsAt,
    endsAt,
    location,
    note,
    repeatRule,
    reminder,
    checklistJson,
    status,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_schedule_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedScheduleEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endsAtMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatRuleMeta);
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderMeta);
    }
    if (data.containsKey('checklist_json')) {
      context.handle(
        _checklistJsonMeta,
        checklistJson.isAcceptableOrUnknown(
          data['checklist_json']!,
          _checklistJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checklistJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedScheduleEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedScheduleEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder'],
      )!,
      checklistJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $CachedScheduleEventsTable createAlias(String alias) {
    return $CachedScheduleEventsTable(attachedDatabase, alias);
  }
}

class CachedScheduleEvent extends DataClass
    implements Insertable<CachedScheduleEvent> {
  final String id;
  final String title;
  final String subject;
  final String type;
  final String format;
  final DateTime startsAt;
  final DateTime endsAt;
  final String location;
  final String note;
  final String repeatRule;
  final String reminder;
  final String checklistJson;
  final String status;
  final DateTime updatedAt;
  final String syncStatus;
  const CachedScheduleEvent({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.format,
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.note,
    required this.repeatRule,
    required this.reminder,
    required this.checklistJson,
    required this.status,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subject'] = Variable<String>(subject);
    map['type'] = Variable<String>(type);
    map['format'] = Variable<String>(format);
    map['starts_at'] = Variable<DateTime>(startsAt);
    map['ends_at'] = Variable<DateTime>(endsAt);
    map['location'] = Variable<String>(location);
    map['note'] = Variable<String>(note);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['reminder'] = Variable<String>(reminder);
    map['checklist_json'] = Variable<String>(checklistJson);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CachedScheduleEventsCompanion toCompanion(bool nullToAbsent) {
    return CachedScheduleEventsCompanion(
      id: Value(id),
      title: Value(title),
      subject: Value(subject),
      type: Value(type),
      format: Value(format),
      startsAt: Value(startsAt),
      endsAt: Value(endsAt),
      location: Value(location),
      note: Value(note),
      repeatRule: Value(repeatRule),
      reminder: Value(reminder),
      checklistJson: Value(checklistJson),
      status: Value(status),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory CachedScheduleEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedScheduleEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subject: serializer.fromJson<String>(json['subject']),
      type: serializer.fromJson<String>(json['type']),
      format: serializer.fromJson<String>(json['format']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      endsAt: serializer.fromJson<DateTime>(json['endsAt']),
      location: serializer.fromJson<String>(json['location']),
      note: serializer.fromJson<String>(json['note']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      reminder: serializer.fromJson<String>(json['reminder']),
      checklistJson: serializer.fromJson<String>(json['checklistJson']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subject': serializer.toJson<String>(subject),
      'type': serializer.toJson<String>(type),
      'format': serializer.toJson<String>(format),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'endsAt': serializer.toJson<DateTime>(endsAt),
      'location': serializer.toJson<String>(location),
      'note': serializer.toJson<String>(note),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'reminder': serializer.toJson<String>(reminder),
      'checklistJson': serializer.toJson<String>(checklistJson),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  CachedScheduleEvent copyWith({
    String? id,
    String? title,
    String? subject,
    String? type,
    String? format,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? note,
    String? repeatRule,
    String? reminder,
    String? checklistJson,
    String? status,
    DateTime? updatedAt,
    String? syncStatus,
  }) => CachedScheduleEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    subject: subject ?? this.subject,
    type: type ?? this.type,
    format: format ?? this.format,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt ?? this.endsAt,
    location: location ?? this.location,
    note: note ?? this.note,
    repeatRule: repeatRule ?? this.repeatRule,
    reminder: reminder ?? this.reminder,
    checklistJson: checklistJson ?? this.checklistJson,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  CachedScheduleEvent copyWithCompanion(CachedScheduleEventsCompanion data) {
    return CachedScheduleEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subject: data.subject.present ? data.subject.value : this.subject,
      type: data.type.present ? data.type.value : this.type,
      format: data.format.present ? data.format.value : this.format,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      location: data.location.present ? data.location.value : this.location,
      note: data.note.present ? data.note.value : this.note,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
      checklistJson: data.checklistJson.present
          ? data.checklistJson.value
          : this.checklistJson,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedScheduleEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subject: $subject, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminder: $reminder, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subject,
    type,
    format,
    startsAt,
    endsAt,
    location,
    note,
    repeatRule,
    reminder,
    checklistJson,
    status,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedScheduleEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.subject == this.subject &&
          other.type == this.type &&
          other.format == this.format &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt &&
          other.location == this.location &&
          other.note == this.note &&
          other.repeatRule == this.repeatRule &&
          other.reminder == this.reminder &&
          other.checklistJson == this.checklistJson &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class CachedScheduleEventsCompanion
    extends UpdateCompanion<CachedScheduleEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subject;
  final Value<String> type;
  final Value<String> format;
  final Value<DateTime> startsAt;
  final Value<DateTime> endsAt;
  final Value<String> location;
  final Value<String> note;
  final Value<String> repeatRule;
  final Value<String> reminder;
  final Value<String> checklistJson;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CachedScheduleEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subject = const Value.absent(),
    this.type = const Value.absent(),
    this.format = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.location = const Value.absent(),
    this.note = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.reminder = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedScheduleEventsCompanion.insert({
    required String id,
    required String title,
    required String subject,
    required String type,
    required String format,
    required DateTime startsAt,
    required DateTime endsAt,
    required String location,
    required String note,
    required String repeatRule,
    required String reminder,
    required String checklistJson,
    required String status,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       subject = Value(subject),
       type = Value(type),
       format = Value(format),
       startsAt = Value(startsAt),
       endsAt = Value(endsAt),
       location = Value(location),
       note = Value(note),
       repeatRule = Value(repeatRule),
       reminder = Value(reminder),
       checklistJson = Value(checklistJson),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<CachedScheduleEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subject,
    Expression<String>? type,
    Expression<String>? format,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? endsAt,
    Expression<String>? location,
    Expression<String>? note,
    Expression<String>? repeatRule,
    Expression<String>? reminder,
    Expression<String>? checklistJson,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subject != null) 'subject': subject,
      if (type != null) 'type': type,
      if (format != null) 'format': format,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (location != null) 'location': location,
      if (note != null) 'note': note,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (reminder != null) 'reminder': reminder,
      if (checklistJson != null) 'checklist_json': checklistJson,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedScheduleEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? subject,
    Value<String>? type,
    Value<String>? format,
    Value<DateTime>? startsAt,
    Value<DateTime>? endsAt,
    Value<String>? location,
    Value<String>? note,
    Value<String>? repeatRule,
    Value<String>? reminder,
    Value<String>? checklistJson,
    Value<String>? status,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CachedScheduleEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      format: format ?? this.format,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      location: location ?? this.location,
      note: note ?? this.note,
      repeatRule: repeatRule ?? this.repeatRule,
      reminder: reminder ?? this.reminder,
      checklistJson: checklistJson ?? this.checklistJson,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<String>(reminder.value);
    }
    if (checklistJson.present) {
      map['checklist_json'] = Variable<String>(checklistJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedScheduleEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subject: $subject, ')
          ..write('type: $type, ')
          ..write('format: $format, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('location: $location, ')
          ..write('note: $note, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('reminder: $reminder, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleSyncOperationsTable extends ScheduleSyncOperations
    with TableInfo<$ScheduleSyncOperationsTable, ScheduleSyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleSyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    operation,
    payload,
    updatedAt,
    nextRetryAt,
    attempts,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleSyncOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleSyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleSyncOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $ScheduleSyncOperationsTable createAlias(String alias) {
    return $ScheduleSyncOperationsTable(attachedDatabase, alias);
  }
}

class ScheduleSyncOperation extends DataClass
    implements Insertable<ScheduleSyncOperation> {
  final int id;
  final String entityId;
  final String operation;
  final String payload;
  final DateTime updatedAt;
  final DateTime? nextRetryAt;
  final int attempts;
  final String status;
  const ScheduleSyncOperation({
    required this.id,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.updatedAt,
    this.nextRetryAt,
    required this.attempts,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    map['attempts'] = Variable<int>(attempts);
    map['status'] = Variable<String>(status);
    return map;
  }

  ScheduleSyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleSyncOperationsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      attempts: Value(attempts),
      status: Value(status),
    );
  }

  factory ScheduleSyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleSyncOperation(
      id: serializer.fromJson<int>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'attempts': serializer.toJson<int>(attempts),
      'status': serializer.toJson<String>(status),
    };
  }

  ScheduleSyncOperation copyWith({
    int? id,
    String? entityId,
    String? operation,
    String? payload,
    DateTime? updatedAt,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    int? attempts,
    String? status,
  }) => ScheduleSyncOperation(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    attempts: attempts ?? this.attempts,
    status: status ?? this.status,
  );
  ScheduleSyncOperation copyWithCompanion(
    ScheduleSyncOperationsCompanion data,
  ) {
    return ScheduleSyncOperation(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSyncOperation(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityId,
    operation,
    payload,
    updatedAt,
    nextRetryAt,
    attempts,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleSyncOperation &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.nextRetryAt == this.nextRetryAt &&
          other.attempts == this.attempts &&
          other.status == this.status);
}

class ScheduleSyncOperationsCompanion
    extends UpdateCompanion<ScheduleSyncOperation> {
  final Value<int> id;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> nextRetryAt;
  final Value<int> attempts;
  final Value<String> status;
  const ScheduleSyncOperationsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
  });
  ScheduleSyncOperationsCompanion.insert({
    this.id = const Value.absent(),
    required String entityId,
    required String operation,
    required String payload,
    required DateTime updatedAt,
    this.nextRetryAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.status = const Value.absent(),
  }) : entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<ScheduleSyncOperation> custom({
    Expression<int>? id,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? nextRetryAt,
    Expression<int>? attempts,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (attempts != null) 'attempts': attempts,
      if (status != null) 'status': status,
    });
  }

  ScheduleSyncOperationsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? nextRetryAt,
    Value<int>? attempts,
    Value<String>? status,
  }) {
    return ScheduleSyncOperationsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('attempts: $attempts, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$ScheduleDatabase extends GeneratedDatabase {
  _$ScheduleDatabase(QueryExecutor e) : super(e);
  $ScheduleDatabaseManager get managers => $ScheduleDatabaseManager(this);
  late final $CachedScheduleEventsTable cachedScheduleEvents =
      $CachedScheduleEventsTable(this);
  late final $ScheduleSyncOperationsTable scheduleSyncOperations =
      $ScheduleSyncOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedScheduleEvents,
    scheduleSyncOperations,
  ];
}

typedef $$CachedScheduleEventsTableCreateCompanionBuilder =
    CachedScheduleEventsCompanion Function({
      required String id,
      required String title,
      required String subject,
      required String type,
      required String format,
      required DateTime startsAt,
      required DateTime endsAt,
      required String location,
      required String note,
      required String repeatRule,
      required String reminder,
      required String checklistJson,
      required String status,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CachedScheduleEventsTableUpdateCompanionBuilder =
    CachedScheduleEventsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> subject,
      Value<String> type,
      Value<String> format,
      Value<DateTime> startsAt,
      Value<DateTime> endsAt,
      Value<String> location,
      Value<String> note,
      Value<String> repeatRule,
      Value<String> reminder,
      Value<String> checklistJson,
      Value<String> status,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CachedScheduleEventsTableFilterComposer
    extends Composer<_$ScheduleDatabase, $CachedScheduleEventsTable> {
  $$CachedScheduleEventsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedScheduleEventsTableOrderingComposer
    extends Composer<_$ScheduleDatabase, $CachedScheduleEventsTable> {
  $$CachedScheduleEventsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedScheduleEventsTableAnnotationComposer
    extends Composer<_$ScheduleDatabase, $CachedScheduleEventsTable> {
  $$CachedScheduleEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);

  GeneratedColumn<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CachedScheduleEventsTableTableManager
    extends
        RootTableManager<
          _$ScheduleDatabase,
          $CachedScheduleEventsTable,
          CachedScheduleEvent,
          $$CachedScheduleEventsTableFilterComposer,
          $$CachedScheduleEventsTableOrderingComposer,
          $$CachedScheduleEventsTableAnnotationComposer,
          $$CachedScheduleEventsTableCreateCompanionBuilder,
          $$CachedScheduleEventsTableUpdateCompanionBuilder,
          (
            CachedScheduleEvent,
            BaseReferences<
              _$ScheduleDatabase,
              $CachedScheduleEventsTable,
              CachedScheduleEvent
            >,
          ),
          CachedScheduleEvent,
          PrefetchHooks Function()
        > {
  $$CachedScheduleEventsTableTableManager(
    _$ScheduleDatabase db,
    $CachedScheduleEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedScheduleEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedScheduleEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedScheduleEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime> endsAt = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> reminder = const Value.absent(),
                Value<String> checklistJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedScheduleEventsCompanion(
                id: id,
                title: title,
                subject: subject,
                type: type,
                format: format,
                startsAt: startsAt,
                endsAt: endsAt,
                location: location,
                note: note,
                repeatRule: repeatRule,
                reminder: reminder,
                checklistJson: checklistJson,
                status: status,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String subject,
                required String type,
                required String format,
                required DateTime startsAt,
                required DateTime endsAt,
                required String location,
                required String note,
                required String repeatRule,
                required String reminder,
                required String checklistJson,
                required String status,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedScheduleEventsCompanion.insert(
                id: id,
                title: title,
                subject: subject,
                type: type,
                format: format,
                startsAt: startsAt,
                endsAt: endsAt,
                location: location,
                note: note,
                repeatRule: repeatRule,
                reminder: reminder,
                checklistJson: checklistJson,
                status: status,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedScheduleEventsTable, CachedScheduleEvent>(
                    table,
                  ),
                  BaseReferences<
                    _$ScheduleDatabase,
                    $CachedScheduleEventsTable,
                    CachedScheduleEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedScheduleEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScheduleDatabase,
      $CachedScheduleEventsTable,
      CachedScheduleEvent,
      $$CachedScheduleEventsTableFilterComposer,
      $$CachedScheduleEventsTableOrderingComposer,
      $$CachedScheduleEventsTableAnnotationComposer,
      $$CachedScheduleEventsTableCreateCompanionBuilder,
      $$CachedScheduleEventsTableUpdateCompanionBuilder,
      (
        CachedScheduleEvent,
        BaseReferences<
          _$ScheduleDatabase,
          $CachedScheduleEventsTable,
          CachedScheduleEvent
        >,
      ),
      CachedScheduleEvent,
      PrefetchHooks Function()
    >;
typedef $$ScheduleSyncOperationsTableCreateCompanionBuilder =
    ScheduleSyncOperationsCompanion Function({
      Value<int> id,
      required String entityId,
      required String operation,
      required String payload,
      required DateTime updatedAt,
      Value<DateTime?> nextRetryAt,
      Value<int> attempts,
      Value<String> status,
    });
typedef $$ScheduleSyncOperationsTableUpdateCompanionBuilder =
    ScheduleSyncOperationsCompanion Function({
      Value<int> id,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<DateTime?> nextRetryAt,
      Value<int> attempts,
      Value<String> status,
    });

class $$ScheduleSyncOperationsTableFilterComposer
    extends Composer<_$ScheduleDatabase, $ScheduleSyncOperationsTable> {
  $$ScheduleSyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleSyncOperationsTableOrderingComposer
    extends Composer<_$ScheduleDatabase, $ScheduleSyncOperationsTable> {
  $$ScheduleSyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleSyncOperationsTableAnnotationComposer
    extends Composer<_$ScheduleDatabase, $ScheduleSyncOperationsTable> {
  $$ScheduleSyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ScheduleSyncOperationsTableTableManager
    extends
        RootTableManager<
          _$ScheduleDatabase,
          $ScheduleSyncOperationsTable,
          ScheduleSyncOperation,
          $$ScheduleSyncOperationsTableFilterComposer,
          $$ScheduleSyncOperationsTableOrderingComposer,
          $$ScheduleSyncOperationsTableAnnotationComposer,
          $$ScheduleSyncOperationsTableCreateCompanionBuilder,
          $$ScheduleSyncOperationsTableUpdateCompanionBuilder,
          (
            ScheduleSyncOperation,
            BaseReferences<
              _$ScheduleDatabase,
              $ScheduleSyncOperationsTable,
              ScheduleSyncOperation
            >,
          ),
          ScheduleSyncOperation,
          PrefetchHooks Function()
        > {
  $$ScheduleSyncOperationsTableTableManager(
    _$ScheduleDatabase db,
    $ScheduleSyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleSyncOperationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduleSyncOperationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduleSyncOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => ScheduleSyncOperationsCompanion(
                id: id,
                entityId: entityId,
                operation: operation,
                payload: payload,
                updatedAt: updatedAt,
                nextRetryAt: nextRetryAt,
                attempts: attempts,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityId,
                required String operation,
                required String payload,
                required DateTime updatedAt,
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => ScheduleSyncOperationsCompanion.insert(
                id: id,
                entityId: entityId,
                operation: operation,
                payload: payload,
                updatedAt: updatedAt,
                nextRetryAt: nextRetryAt,
                attempts: attempts,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScheduleSyncOperationsTable,
                    ScheduleSyncOperation
                  >(table),
                  BaseReferences<
                    _$ScheduleDatabase,
                    $ScheduleSyncOperationsTable,
                    ScheduleSyncOperation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleSyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ScheduleDatabase,
      $ScheduleSyncOperationsTable,
      ScheduleSyncOperation,
      $$ScheduleSyncOperationsTableFilterComposer,
      $$ScheduleSyncOperationsTableOrderingComposer,
      $$ScheduleSyncOperationsTableAnnotationComposer,
      $$ScheduleSyncOperationsTableCreateCompanionBuilder,
      $$ScheduleSyncOperationsTableUpdateCompanionBuilder,
      (
        ScheduleSyncOperation,
        BaseReferences<
          _$ScheduleDatabase,
          $ScheduleSyncOperationsTable,
          ScheduleSyncOperation
        >,
      ),
      ScheduleSyncOperation,
      PrefetchHooks Function()
    >;

class $ScheduleDatabaseManager {
  final _$ScheduleDatabase _db;
  $ScheduleDatabaseManager(this._db);
  $$CachedScheduleEventsTableTableManager get cachedScheduleEvents =>
      $$CachedScheduleEventsTableTableManager(_db, _db.cachedScheduleEvents);
  $$ScheduleSyncOperationsTableTableManager get scheduleSyncOperations =>
      $$ScheduleSyncOperationsTableTableManager(
        _db,
        _db.scheduleSyncOperations,
      );
}
