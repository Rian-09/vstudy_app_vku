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
    required this.content,
    this.summaryId,
    this.documentId,
  });

  final String title;
  final String content;
  final String? summaryId;
  final String? documentId;
}

@immutable
class AiSummaryRequest {
  const AiSummaryRequest({
    required this.title,
    this.documentId,
    this.fileName,
    this.contentType,
    this.bytes,
  }) : assert(documentId != null || (fileName != null && bytes != null));

  final String title;
  final String? documentId;
  final String? fileName;
  final String? contentType;
  final Uint8List? bytes;
}
