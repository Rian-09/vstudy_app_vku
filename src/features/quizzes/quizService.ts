import { requireSupabase } from '../../lib/supabase/client';
import type {
  QuizDraft,
  QuizMode,
  QuizPage,
  QuizSort,
  QuizSubject,
  QuizSummary,
} from './types';

const QUIZ_COLUMNS =
  'id, subject_id, title, description, duration_minutes, mode, is_published, created_at, subjects(name), quiz_questions(count)';

interface QuizFilters {
  page: number;
  pageSize: number;
  search: string;
  subjectId: string;
  mode: QuizMode | 'all';
  status: 'draft' | 'published' | 'all';
  sort: QuizSort;
}

export async function fetchQuizSubjects(): Promise<QuizSubject[]> {
  const { data, error } = await requireSupabase()
    .from('subjects')
    .select('id, code, name')
    .eq('is_active', true)
    .order('name');
  if (error) throw error;
  return (data ?? []) as QuizSubject[];
}

export async function fetchQuizzes({
  page,
  pageSize,
  search,
  subjectId,
  mode,
  status,
  sort,
}: QuizFilters): Promise<QuizPage> {
  const from = page * pageSize;
  let query = requireSupabase()
    .from('quizzes')
    .select(QUIZ_COLUMNS, { count: 'exact' });

  if (subjectId) query = query.eq('subject_id', subjectId);
  if (mode !== 'all') query = query.eq('mode', mode);
  if (status !== 'all') {
    query = query.eq('is_published', status === 'published');
  }
  if (search.trim()) {
    const escaped = search
      .trim()
      .replace(/\\/g, '\\\\')
      .replace(/"/g, '\\"')
      .replace(/[(),]/g, '\\$&');
    query = query.or(
      `title.ilike."%${escaped}%",description.ilike."%${escaped}%"`,
    );
  }

  if (sort === 'title') query = query.order('title', { ascending: true });
  else query = query.order('created_at', { ascending: sort === 'oldest' });
  const { data, error, count } = await query.range(
    from,
    from + pageSize - 1,
  );
  if (error) throw error;

  const quizzes = (data ?? []).map((row) => {
    const subjectJoin = Array.isArray(row.subjects)
      ? row.subjects[0]
      : row.subjects;
    const questionJoin = Array.isArray(row.quiz_questions)
      ? row.quiz_questions[0]
      : row.quiz_questions;
    return {
      id: row.id,
      subject_id: row.subject_id,
      subject_name: subjectJoin?.name ?? 'Chưa phân loại',
      title: row.title,
      description: row.description ?? '',
      duration_minutes: row.duration_minutes,
      mode: row.mode,
      is_published: row.is_published,
      created_at: row.created_at,
      question_count: questionJoin?.count ?? 0,
    };
  }) as QuizSummary[];

  return { quizzes, total: count ?? 0 };
}

export async function fetchQuiz(quizId: string): Promise<QuizDraft> {
  const { data, error } = await requireSupabase()
    .from('quizzes')
    .select(
      'id, subject_id, title, description, duration_minutes, mode, shuffle_options, is_published, quiz_questions(id, question_text, explanation, sort_order, quiz_options(option_text, option_index, is_correct))',
    )
    .eq('id', quizId)
    .single();
  if (error) throw error;

  const questions = [...(data.quiz_questions ?? [])]
    .sort((left, right) => left.sort_order - right.sort_order)
    .map((question) => {
      const options = [...(question.quiz_options ?? [])].sort(
        (left, right) => left.option_index - right.option_index,
      );
      if (options.length !== 4) {
        throw new Error(
          `Câu hỏi "${question.question_text}" không có đủ bốn lựa chọn.`,
        );
      }
      const correctIndex = options.findIndex((option) => option.is_correct);
      if (correctIndex < 0) {
        throw new Error(
          `Câu hỏi "${question.question_text}" chưa có đáp án đúng.`,
        );
      }
      return {
        id: question.id,
        questionText: question.question_text,
        options: options.map((option) => option.option_text) as [
          string,
          string,
          string,
          string,
        ],
        correctIndex,
        explanation: question.explanation ?? '',
      };
    });

  return {
    title: data.title,
    subjectId: data.subject_id,
    description: data.description ?? '',
    durationMinutes: data.duration_minutes,
    mode: data.mode === 'exam' ? 'exam' : 'practice',
    shuffleOptions: data.shuffle_options,
    isPublished: data.is_published,
    questions,
  };
}

export async function saveQuiz(quizId: string | null, quiz: QuizDraft) {
  const { data, error } = await requireSupabase().rpc('admin_save_quiz', {
    p_quiz_id: quizId,
    p_subject_id: quiz.subjectId,
    p_title: quiz.title.trim(),
    p_description: quiz.description.trim(),
    p_duration_minutes: quiz.durationMinutes,
    p_is_published: quiz.isPublished,
    p_mode: quiz.mode,
    p_shuffle_options: quiz.shuffleOptions,
    p_questions: quiz.questions.map((question) => ({
      id: question.id,
      questionText: question.questionText.trim(),
      options: question.options.map((option) => option.trim()),
      correctIndex: question.correctIndex,
      explanation: question.explanation.trim(),
    })),
  });
  if (error) throw error;
  return data as string;
}

export async function deleteQuiz(quizId: string) {
  const { error } = await requireSupabase().rpc('admin_delete_quiz', {
    p_quiz_id: quizId,
  });
  if (error) throw error;
}
