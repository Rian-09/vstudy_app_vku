import 'package:flutter/foundation.dart';

@immutable
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.questionCount,
    required this.examCount,
    required this.rating,
    required this.progress,
  });

  final String id;
  final String name;
  final String imageAsset;
  final int questionCount;
  final int examCount;
  final double rating;
  final double progress;
}

@immutable
class Exam {
  const Exam({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.chapterTitle,
    required this.questionCount,
    required this.durationMinutes,
    required this.difficulty,
    required this.questions,
    this.score,
    this.isCompleted = false,
  });

  final String id;
  final String subjectId;
  final String title;
  final String chapterTitle;
  final int questionCount;
  final int durationMinutes;
  final int difficulty;
  final List<Question> questions;
  final double? score;
  final bool isCompleted;
}

@immutable
class Question {
  const Question({
    required this.id,
    required this.examId,
    required this.topic,
    required this.chapterTitle,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.previousAnswerIndex,
    this.wrongCount = 0,
  }) : assert(options.length == 4);

  final String id;
  final String examId;
  final String topic;
  final String chapterTitle;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int? previousAnswerIndex;
  final int wrongCount;

  bool get wasAnsweredIncorrectly =>
      previousAnswerIndex != null && previousAnswerIndex != correctIndex;

  Question copyWith({int? previousAnswerIndex, int? wrongCount}) => Question(
    id: id,
    examId: examId,
    topic: topic,
    chapterTitle: chapterTitle,
    text: text,
    options: options,
    correctIndex: correctIndex,
    explanation: explanation,
    previousAnswerIndex: previousAnswerIndex ?? this.previousAnswerIndex,
    wrongCount: wrongCount ?? this.wrongCount,
  );
}

@immutable
class QuizResult {
  const QuizResult({
    required this.examId,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.durationMinutes,
    required this.score,
    required this.completedAt,
    this.answers = const [],
    this.checkedQuestions = const [],
    this.durationSeconds = 0,
    this.topicCorrectCounts = const {},
    this.topicTotalCounts = const {},
  });

  final String examId;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final int durationMinutes;
  final double score;
  final DateTime completedAt;
  final List<int?> answers;
  final List<bool> checkedQuestions;
  final int durationSeconds;
  final Map<String, int> topicCorrectCounts;
  final Map<String, int> topicTotalCounts;
}

@immutable
class QuizPlayArguments {
  const QuizPlayArguments({required this.examId, this.isTimed = false});

  final String examId;
  final bool isTimed;
}
