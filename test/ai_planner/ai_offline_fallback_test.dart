import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/ai_planner/domain/services/ai_offline_fallback.dart';

void main() {
  const fallback = AiOfflineFallback();

  test('gives schedule guidance for a deadline question', () {
    expect(fallback.answerFor('Deadline nào cần làm trước?'), contains('offline'));
  });

  test('explains that new document analysis needs a connection', () {
    expect(fallback.answerFor('Tóm tắt tài liệu này'), contains('tài liệu'));
  });
}
