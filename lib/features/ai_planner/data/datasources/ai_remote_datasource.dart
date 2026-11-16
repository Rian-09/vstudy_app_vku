import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/ai_answer.dart';

class AiRemoteDataSource {
  AiRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<AiAnswer> ask(String question, {String? context}) async {
    final response = await _client.functions.invoke(
      'ai-assistant',
      body: {
        'question': question,
        if (context != null && context.trim().isNotEmpty) 'context': context,
      },
    );

    final data = response.data;
    if (data is! Map || data['answer'] is! String) {
      throw const FormatException('Phản hồi AI không đúng định dạng.');
    }

    return AiAnswer(
      answer: (data['answer'] as String).trim(),
      model: data['model'] as String? ?? 'gemini-3.8-flash',
    );
  }
}
