import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/ai_answer.dart';

class AiAnswerCache {
  static const _answerKey = 'ai_planner.latest_answer';
  static const _modelKey = 'ai_planner.latest_model';

  Future<AiAnswer?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final answer = preferences.getString(_answerKey);
    if (answer == null || answer.trim().isEmpty) return null;
    return AiAnswer(
      answer: answer,
      model: preferences.getString(_modelKey) ?? 'cached',
    );
  }

  Future<void> write(AiAnswer value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_answerKey, value.answer);
    await preferences.setString(_modelKey, value.model);
  }
}
