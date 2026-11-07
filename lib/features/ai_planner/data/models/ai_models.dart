import 'package:flutter/foundation.dart';

@immutable
class AiChatMessage {
  const AiChatMessage({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}

@immutable
class AiRoadmapTask {
  const AiRoadmapTask({
    required this.title,
    required this.subtitle,
    this.done = false,
  });

  final String title;
  final String subtitle;
  final bool done;

  AiRoadmapTask copyWith({bool? done}) =>
      AiRoadmapTask(title: title, subtitle: subtitle, done: done ?? this.done);
}

@immutable
class AiSummaryData {
  const AiSummaryData({
    required this.title,
    required this.shortText,
    required this.detailText,
  });

  final String title;
  final String shortText;
  final String detailText;
}
