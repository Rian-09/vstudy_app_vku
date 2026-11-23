import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/quiz/data/models/quiz_models.dart';

void main() {
  test(
    'shuffling options preserves the correct answer and stored positions',
    () {
      for (var correctIndex = 0; correctIndex < 4; correctIndex++) {
        final question = Question(
          id: 'question-$correctIndex',
          examId: 'quiz',
          topic: 'Topic',
          chapterTitle: 'Chapter',
          text: 'Question',
          options: const ['Option A', 'Option B', 'Option C', 'Option D'],
          correctIndex: correctIndex,
          explanation: '',
        );

        final shuffled = question.shuffleOptions(random: Random(correctIndex));

        expect(shuffled.options.toSet(), question.options.toSet());
        expect(
          shuffled.options[shuffled.correctIndex],
          question.options[correctIndex],
        );
        expect(shuffled.optionOrder[shuffled.correctIndex], correctIndex);
        expect(shuffled.optionOrder.toSet(), {0, 1, 2, 3});
      }
    },
  );
}
