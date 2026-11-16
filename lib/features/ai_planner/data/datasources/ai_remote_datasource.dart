import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/ai_answer.dart';
import '../models/ai_models.dart';

class AiRemoteDataSource {
  AiRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<AiSummaryData>> getSummaryHistory() async {
    final response = await _client
        .from('ai_summaries')
        .select('id,document_id,source_name,content')
        .order('created_at', ascending: false)
        .limit(30);
    return (response as List)
        .whereType<Map<String, dynamic>>()
        .map(
          (row) => AiSummaryData(
            title: row['source_name'] as String? ?? 'Tài liệu',
            content: row['content'] as String? ?? '',
            summaryId: row['id'] as String?,
            documentId: row['document_id'] as String?,
          ),
        )
        .toList(growable: false);
  }

  Future<AiSummaryData> summarize({
    required String title,
    String? documentId,
    String? fileName,
    String? contentType,
    Uint8List? bytes,
  }) async {
    final response = await _client.functions.invoke(
      'ai-gateway',
      body: {
        'action': 'summarize',
        'document_id': ?documentId,
        if (documentId == null && fileName != null && bytes != null)
          'uploaded_file': {
            'name': fileName,
            'content_type': contentType ?? 'application/octet-stream',
            'base64': base64Encode(bytes),
          },
      },
    );
    final data = response.data;
    final summary = data is Map ? data['summary'] : null;
    if (summary is! Map || summary['content'] is! String) {
      throw const FormatException('Phản hồi tóm tắt không đúng định dạng.');
    }
    return AiSummaryData(
      title: summary['source_name'] as String? ?? title,
      content: (summary['content'] as String).trim(),
      summaryId: summary['id'] as String?,
      documentId: summary['document_id'] as String?,
    );
  }

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
