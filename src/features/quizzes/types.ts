export type QuizMode = 'practice' | 'exam';
export type QuizStatus = 'draft' | 'published';
export type QuizSort = 'newest' | 'oldest' | 'title';

export interface QuizSubject {
  id: string;
  code: string;
  name: string;
  major_id?: string | null;
}

export interface QuizQuestionDraft {
  id?: string;
  questionText: string;
  options: [string, string, string, string];
  correctIndex: number;
  explanation: string;
}

export interface QuizDraft {
  title: string;
  subjectId: string;
  description: string;
  durationMinutes: number;
  mode: QuizMode;
  shuffleOptions: boolean;
  isPublished: boolean;
  questions: QuizQuestionDraft[];
}

export interface QuizSummary {
  id: string;
  subject_id: string;
  subject_name: string;
  title: string;
  description: string;
  duration_minutes: number;
  mode: QuizMode;
  is_published: boolean;
  created_at: string;
  question_count: number;
}

export interface QuizPage {
  quizzes: QuizSummary[];
  total: number;
}
