import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudySessionRecord {
  const StudySessionRecord({required this.startedAt, required this.endedAt});

  final DateTime startedAt;
  final DateTime endedAt;

  int get durationMinutes => endedAt.difference(startedAt).inMinutes.clamp(0, 24 * 60);

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
      };

  static StudySessionRecord? fromJson(Map<String, dynamic> json) {
    final startedAt = DateTime.tryParse(json['startedAt'] as String? ?? '');
    final endedAt = DateTime.tryParse(json['endedAt'] as String? ?? '');
    if (startedAt == null || endedAt == null || !endedAt.isAfter(startedAt)) {
      return null;
    }
    return StudySessionRecord(startedAt: startedAt, endedAt: endedAt);
  }
}

/// Tracks foreground time. A session is closed whenever the app is paused or
/// the user logs out. This is intentionally local-first and keyed by user id.
class StudySessionService with WidgetsBindingObserver, ChangeNotifier {
  StudySessionService._();

  static final StudySessionService instance = StudySessionService._();

  String? _userId;
  DateTime? _startedAt;
  List<StudySessionRecord> _records = const [];

  bool get hasActiveSession => _startedAt != null;
  List<StudySessionRecord> get records => List.unmodifiable(_records);

  Future<void> startForUser(String userId) async {
    if (_userId == userId && _startedAt != null) return;
    await stop();
    _userId = userId;
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey(userId));
    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _records = decoded
            .whereType<Map>()
            .map((item) => StudySessionRecord.fromJson(Map<String, dynamic>.from(item)))
            .whereType<StudySessionRecord>()
            .toList(growable: false);
      }
    }
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_userId != null && _startedAt == null) {
        _startedAt = DateTime.now();
        notifyListeners();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(stop());
    }
  }

  Future<void> stop() async {
    final startedAt = _startedAt;
    final userId = _userId;
    _startedAt = null;
    if (startedAt == null || userId == null) return;
    WidgetsBinding.instance.removeObserver(this);
    final endedAt = DateTime.now();
    if (endedAt.difference(startedAt).inSeconds < 1) return;
    _records = [..._records, StudySessionRecord(startedAt: startedAt, endedAt: endedAt)];
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey(userId),
      jsonEncode(_records.map((record) => record.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> clear() async {
    await stop();
    _userId = null;
    _records = const [];
    notifyListeners();
  }

  List<StudySessionRecord> recordsForDate(DateTime date) {
    return _records.where((record) {
      return record.startedAt.year == date.year &&
          record.startedAt.month == date.month &&
          record.startedAt.day == date.day;
    }).toList(growable: false);
  }

  int minutesForDate(DateTime date) => recordsForDate(date)
      .fold(0, (total, record) => total + record.durationMinutes);

  String _storageKey(String userId) => 'vstudy.study_sessions.$userId';
}
