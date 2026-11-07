import 'package:flutter/foundation.dart';

enum StatsPeriod { week, month, semester }

extension StatsPeriodLabel on StatsPeriod {
  String get label => switch (this) {
    StatsPeriod.week => 'Tuần',
    StatsPeriod.month => 'Tháng',
    StatsPeriod.semester => 'Học kỳ',
  };
}

@immutable
class StudyDayStat {
  const StudyDayStat({required this.date, required this.minutes});

  final DateTime date;
  final int minutes;

  double get hours => minutes / 60;
}

@immutable
class StudyActivity {
  const StudyActivity({
    required this.time,
    required this.title,
    required this.description,
    required this.durationMinutes,
  });

  final String time;
  final String title;
  final String description;
  final int durationMinutes;
}

@immutable
class ChapterProgress {
  const ChapterProgress({required this.title, required this.progress});

  final String title;
  final double progress;
}

@immutable
class SubjectStudyStats {
  const SubjectStudyStats({
    required this.name,
    required this.credits,
    required this.minutes,
    required this.quizScore,
    required this.flashcardCount,
    required this.completedExercises,
    required this.totalExercises,
    required this.chapters,
  });

  final String name;
  final int credits;
  final int minutes;
  final int quizScore;
  final int flashcardCount;
  final int completedExercises;
  final int totalExercises;
  final List<ChapterProgress> chapters;
}

@immutable
class StudyInsight {
  const StudyInsight({required this.title, required this.detail});

  final String title;
  final String detail;
}

@immutable
class ReviewErrorStat {
  const ReviewErrorStat({
    required this.label,
    required this.count,
    required this.colorValue,
  });

  final String label;
  final int count;
  final int colorValue;
}

@immutable
class FlashcardTopicStat {
  const FlashcardTopicStat({
    required this.title,
    required this.detail,
    required this.reviewed,
    required this.total,
  });

  final String title;
  final String detail;
  final int reviewed;
  final int total;

  double get progress => total == 0 ? 0 : reviewed / total;
}
