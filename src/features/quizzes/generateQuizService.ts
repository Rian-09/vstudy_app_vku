import { z } from 'zod';
import { requireSupabase } from '../../lib/supabase/client';

const generatedQuestionSchema = z.object({
  question: z.string().trim().min(1),
  options: z.tuple([
    z.string().trim().min(1),
    z.string().trim().min(1),
    z.string().trim().min(1),
    z.string().trim().min(1),
  ]),
  correctIndex: z.number().int().min(0).max(3),
  explanation: z.string(),
});

const generateResponseSchema = z.object({
  questions: z.array(generatedQuestionSchema),
  model: z.string(),
});

export type GeneratedQuestion = z.infer<typeof generatedQuestionSchema>;

export interface GenerateQuizRequest {
  documentId: string;
  subjectId: string;
  questionCount: number;
  durationMinutes: number;
  mode: 'practice' | 'exam';
  difficulty: 'easy' | 'medium' | 'hard' | '';
}

export async function generateQuizQuestions(
  request: GenerateQuizRequest,
): Promise<GeneratedQuestion[]> {
  const { data, error } = await requireSupabase().functions.invoke(
    'generate-quiz',
    {
      body: {
        document_id: request.documentId,
        subject_id: request.subjectId,
        question_count: request.questionCount,
        duration_minutes: request.durationMinutes,
        mode: request.mode,
        ...(request.difficulty ? { difficulty: request.difficulty } : {}),
      },
    },
  );
  if (error) {
    let message = error.message;
    if ('context' in error && error.context instanceof Response) {
      const response = error.context.clone();
      const body = await response.json().catch(() => null);
      if (typeof body?.error === 'string') message = body.error;
      if (
        response.status === 404 &&
        body?.code !== 'document_not_found'
      ) {
        message =
          'Edge Function generate-quiz chưa được deploy lên Supabase. Hãy deploy function rồi thử lại.';
      }
    }
    throw new Error(message || 'Không thể tạo quiz.');
  }

  const parsed = generateResponseSchema.safeParse(data);
  if (!parsed.success) {
    throw new Error('Dữ liệu quiz AI trả về không hợp lệ. Vui lòng thử lại.');
  }
  if (parsed.data.questions.length !== request.questionCount) {
    throw new Error('AI không tạo đủ số câu hỏi đã yêu cầu.');
  }
  return parsed.data.questions;
}
