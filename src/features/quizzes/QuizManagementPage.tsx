import { useQuery, useQueryClient } from '@tanstack/react-query';
import {
  BookOpenCheck,
  ChevronLeft,
  ChevronRight,
  FilePlus2,
  Pencil,
  Search,
  Sparkles,
  Trash2,
} from 'lucide-react';
import { useEffect, useState } from 'react';
import { toast } from 'sonner';
import { Button } from '../../components/ui/button';
import { ConfirmDialog } from '../../components/ui/confirm-dialog';
import { Input } from '../../components/ui/input';
import { fetchQuizDocuments } from '../documents/documentService';
import { GenerateQuizDialog } from './GenerateQuizDialog';
import {
  deleteQuiz,
  fetchQuiz,
  fetchQuizzes,
  fetchQuizSubjects,
  saveQuiz,
} from './quizService';
import { QuizEditorDialog } from './QuizEditorDialog';
import type {
  QuizDraft,
  QuizMode,
  QuizSort,
  QuizStatus,
  QuizSummary,
} from './types';

const PAGE_SIZE = 10;

interface QuizEditorState {
  quizId: string | null;
  quiz: QuizDraft | null;
  isLoading: boolean;
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat('vi-VN', { dateStyle: 'medium' }).format(
    new Date(value),
  );
}

function errorText(error: unknown) {
  return error instanceof Error ? error.message : 'Vui lòng thử lại.';
}

export function QuizManagementPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [subjectId, setSubjectId] = useState('');
  const [mode, setMode] = useState<QuizMode | 'all'>('all');
  const [status, setStatus] = useState<QuizStatus | 'all'>('all');
  const [sort, setSort] = useState<QuizSort>('newest');
  const [editor, setEditor] = useState<QuizEditorState | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isSavingGeneratedQuiz, setIsSavingGeneratedQuiz] = useState(false);
  const [isGenerateDialogOpen, setIsGenerateDialogOpen] = useState(false);
  const [quizToDelete, setQuizToDelete] = useState<QuizSummary | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    const timer = window.setTimeout(
      () => setDebouncedSearch(search.trim()),
      250,
    );
    return () => window.clearTimeout(timer);
  }, [search]);

  const subjectsQuery = useQuery({
    queryKey: ['quiz-subjects'],
    queryFn: fetchQuizSubjects,
  });
  const documentsQuery = useQuery({
    queryKey: ['admin-documents'],
    queryFn: fetchQuizDocuments,
  });
  const quizzesQuery = useQuery({
    queryKey: [
      'admin-quizzes',
      page,
      debouncedSearch,
      subjectId,
      mode,
      status,
      sort,
    ],
    queryFn: () =>
      fetchQuizzes({
        page,
        pageSize: PAGE_SIZE,
        search: debouncedSearch,
        subjectId,
        mode,
        status,
        sort,
      }),
  });

  const subjects = subjectsQuery.data ?? [];
  const quizzes = quizzesQuery.data?.quizzes ?? [];
  const total = quizzesQuery.data?.total ?? 0;
  const pageCount = Math.max(1, Math.ceil(total / PAGE_SIZE));

  const resetPage = () => setPage(0);
  const openNewQuiz = () =>
    setEditor({ quizId: null, quiz: null, isLoading: false });

  const openExistingQuiz = async (quizId: string) => {
    setEditor({ quizId, quiz: null, isLoading: true });
    try {
      const quiz = await fetchQuiz(quizId);
      setEditor({ quizId, quiz, isLoading: false });
    } catch (error) {
      setEditor(null);
      toast.error(`Không tải được quiz: ${errorText(error)}`);
    }
  };

  const handleSave = async (quiz: QuizDraft) => {
    if (!editor) return;
    setIsSaving(true);
    try {
      await saveQuiz(editor.quizId, quiz);
      toast.success(
        quiz.isPublished ? 'Đã lưu và publish quiz.' : 'Đã lưu bản nháp.',
      );
      setEditor(null);
      await queryClient.invalidateQueries({ queryKey: ['admin-quizzes'] });
    } catch (error) {
      toast.error(`Không lưu được quiz: ${errorText(error)}`);
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!quizToDelete) return;
    setIsDeleting(true);
    try {
      await deleteQuiz(quizToDelete.id);
      toast.success('Đã xóa quiz.');
      setQuizToDelete(null);
      await queryClient.invalidateQueries({ queryKey: ['admin-quizzes'] });
    } catch (error) {
      toast.error(errorText(error));
    } finally {
      setIsDeleting(false);
    }
  };

  const handleSaveGeneratedQuiz = async (quiz: QuizDraft) => {
    setIsSavingGeneratedQuiz(true);
    try {
      await saveQuiz(null, quiz);
      toast.success(
        quiz.isPublished ? 'Đã lưu và publish quiz.' : 'Đã lưu bản nháp.',
      );
      await queryClient.invalidateQueries({ queryKey: ['admin-quizzes'] });
    } finally {
      setIsSavingGeneratedQuiz(false);
    }
  };

  const updateFilter = <T,>(setValue: (value: T) => void, value: T) => {
    setValue(value);
    resetPage();
  };

  const isLoading = quizzesQuery.isPending || subjectsQuery.isPending;
  const loadError = quizzesQuery.error ?? subjectsQuery.error;

  return (
    <div className="space-y-6">
      <header className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
            Ngân hàng câu hỏi
          </p>
          <h1 className="mt-2 text-2xl font-bold text-brand-ink">
            Quản lý quiz
          </h1>
          <p className="mt-1 text-sm text-brand-muted">
            Tạo quiz luyện tập hoặc luyện thi, quản lý câu hỏi và trạng thái
            publish.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            variant="outline"
            onClick={() => setIsGenerateDialogOpen(true)}
          >
            <Sparkles size={17} />
            Tạo quiz bằng AI
          </Button>
          <Button variant="yellow" onClick={openNewQuiz}>
            <FilePlus2 size={17} />
            Tạo quiz
          </Button>
        </div>
      </header>

      <section className="rounded-2xl border border-slate-100 bg-white p-4 shadow-sm sm:p-5">
        <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-[minmax(220px,1fr)_190px_150px_150px_150px]">
          <label className="relative block">
            <Search
              size={17}
              className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"
            />
            <Input
              value={search}
              onChange={(event) => {
                setSearch(event.target.value);
                resetPage();
              }}
              placeholder="Tìm tiêu đề hoặc mô tả..."
              aria-label="Tìm quiz"
              className="pl-10"
            />
          </label>
          <select
            value={subjectId}
            onChange={(event) =>
              updateFilter(setSubjectId, event.target.value)
            }
            className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
            aria-label="Lọc theo môn học"
          >
            <option value="">Tất cả môn học</option>
            {subjects.map((subject) => (
              <option key={subject.id} value={subject.id}>
                {subject.code} · {subject.name}
              </option>
            ))}
          </select>
          <select
            value={mode}
            onChange={(event) =>
              updateFilter(setMode, event.target.value as QuizMode | 'all')
            }
            className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
            aria-label="Lọc theo chế độ"
          >
            <option value="all">Mọi chế độ</option>
            <option value="practice">Luyện tập</option>
            <option value="exam">Luyện thi</option>
          </select>
          <select
            value={status}
            onChange={(event) =>
              updateFilter(
                setStatus,
                event.target.value as QuizStatus | 'all',
              )
            }
            className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
            aria-label="Lọc theo trạng thái"
          >
            <option value="all">Mọi trạng thái</option>
            <option value="draft">Bản nháp</option>
            <option value="published">Đã publish</option>
          </select>
          <select
            value={sort}
            onChange={(event) =>
              updateFilter(setSort, event.target.value as QuizSort)
            }
            className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
            aria-label="Sắp xếp quiz"
          >
            <option value="newest">Mới nhất</option>
            <option value="oldest">Cũ nhất</option>
            <option value="title">Tên A–Z</option>
          </select>
        </div>

        {isLoading ? (
          <div className="mt-5 space-y-3" aria-label="Đang tải quiz">
            {Array.from({ length: 5 }, (_, index) => (
              <div
                key={index}
                className="h-16 animate-pulse rounded-xl bg-slate-100"
              />
            ))}
          </div>
        ) : loadError ? (
          <div
            role="alert"
            className="mt-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-800"
          >
            <p className="font-semibold">Không tải được danh sách quiz.</p>
            <p className="mt-1 break-words">{errorText(loadError)}</p>
            <Button
              variant="outline"
              size="sm"
              className="mt-3"
              onClick={() => {
                void quizzesQuery.refetch();
                void subjectsQuery.refetch();
              }}
            >
              Thử tải lại
            </Button>
          </div>
        ) : (
          <>
            <div className="mt-4 flex items-center justify-between border-b border-slate-100 py-3">
              <h2 className="text-sm font-bold text-brand-ink">Danh sách quiz</h2>
              <span className="text-xs text-brand-muted">
                {total.toLocaleString('vi-VN')} quiz
              </span>
            </div>
            <div className="mt-2 overflow-x-auto">
              <table className="w-full min-w-[850px] border-collapse text-left">
                <thead>
                  <tr className="text-[11px] font-bold uppercase tracking-wide text-slate-400">
                    <th className="px-3 py-3">Quiz</th>
                    <th className="px-3 py-3">Môn học</th>
                    <th className="px-3 py-3">Chế độ</th>
                    <th className="px-3 py-3">Câu hỏi</th>
                    <th className="px-3 py-3">Trạng thái</th>
                    <th className="px-3 py-3">Ngày tạo</th>
                    <th className="px-3 py-3 text-right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  {quizzes.map((quiz) => (
                    <QuizRow
                      key={quiz.id}
                      quiz={quiz}
                      onEdit={() => void openExistingQuiz(quiz.id)}
                      onDelete={() => setQuizToDelete(quiz)}
                    />
                  ))}
                  {quizzes.length === 0 && (
                    <tr>
                      <td
                        colSpan={7}
                        className="px-3 py-12 text-center text-sm text-brand-muted"
                      >
                        Chưa có quiz phù hợp với bộ lọc.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>

            <footer className="mt-4 flex flex-col gap-3 border-t border-slate-100 pt-4 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-xs text-brand-muted">
                {total === 0
                  ? '0 quiz'
                  : `${page * PAGE_SIZE + 1}–${Math.min(
                      (page + 1) * PAGE_SIZE,
                      total,
                    )} trong ${total.toLocaleString('vi-VN')} quiz`}
              </p>
              <div className="flex items-center justify-end gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  aria-label="Trang trước"
                  disabled={page === 0}
                  onClick={() => setPage((current) => Math.max(0, current - 1))}
                >
                  <ChevronLeft size={16} />
                  Trước
                </Button>
                <span className="min-w-20 text-center text-xs text-brand-muted">
                  Trang {page + 1} / {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  aria-label="Trang sau"
                  disabled={page + 1 >= pageCount}
                  onClick={() =>
                    setPage((current) => Math.min(pageCount - 1, current + 1))
                  }
                >
                  Sau
                  <ChevronRight size={16} />
                </Button>
              </div>
            </footer>
          </>
        )}
      </section>

      {editor && (
        <QuizEditorDialog
          key={`${editor.quizId ?? 'new'}-${editor.isLoading ? 'loading' : 'ready'}`}
          quizId={editor.quizId}
          initialQuiz={editor.quiz}
          subjects={subjects}
          isLoading={editor.isLoading}
          isSaving={isSaving}
          onClose={() => {
            if (!isSaving) setEditor(null);
          }}
          onSave={handleSave}
        />
      )}

      {isGenerateDialogOpen && (
        <GenerateQuizDialog
          documents={documentsQuery.data ?? []}
          subjects={subjects}
          documentsLoading={documentsQuery.isPending || subjectsQuery.isPending}
          documentsError={documentsQuery.error ?? subjectsQuery.error}
          onClose={() => {
            if (!isSavingGeneratedQuiz) setIsGenerateDialogOpen(false);
          }}
          onDocumentUploaded={() => {
            void queryClient.invalidateQueries({
              queryKey: ['admin-documents'],
            });
          }}
          onSave={handleSaveGeneratedQuiz}
        />
      )}

      {quizToDelete && (
        <ConfirmDialog
          title="Xóa quiz này?"
          description={`"${quizToDelete.title}" chỉ xóa được khi chưa có lượt làm bài. Nếu đã có lượt làm, hãy chuyển quiz về bản nháp để giữ lịch sử.`}
          confirmLabel="Xóa quiz"
          isDestructive
          isPending={isDeleting}
          onCancel={() => setQuizToDelete(null)}
          onConfirm={() => void handleDelete()}
        />
      )}
    </div>
  );
}

function QuizRow({
  quiz,
  onEdit,
  onDelete,
}: {
  quiz: QuizSummary;
  onEdit: () => void;
  onDelete: () => void;
}) {
  return (
    <tr className="border-t border-slate-50 hover:bg-slate-50/70">
      <td className="max-w-[280px] px-3 py-3.5">
        <div className="flex items-center gap-2.5">
          <span className="grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-amber-50 text-amber-700">
            <BookOpenCheck size={16} />
          </span>
          <span className="min-w-0">
            <span className="block truncate text-sm font-semibold text-brand-ink">
              {quiz.title}
            </span>
            <span className="block truncate text-xs text-brand-muted">
              {quiz.description || 'Không có mô tả'}
            </span>
          </span>
        </div>
      </td>
      <td className="px-3 py-3.5 text-sm text-brand-muted">{quiz.subject_name}</td>
      <td className="px-3 py-3.5">
        <span
          className={`rounded-full px-2.5 py-1 text-xs font-semibold ${
            quiz.mode === 'exam'
              ? 'bg-blue-50 text-brand-blue'
              : 'bg-amber-50 text-amber-800'
          }`}
        >
          {quiz.mode === 'exam' ? 'Luyện thi' : 'Luyện tập'}
          {quiz.mode === 'exam' ? ` · ${quiz.duration_minutes} phút` : ''}
        </span>
      </td>
      <td className="px-3 py-3.5 text-sm text-brand-muted">
        {quiz.question_count}
      </td>
      <td className="px-3 py-3.5">
        <span
          className={`rounded-full px-2.5 py-1 text-xs font-semibold ${
            quiz.is_published
              ? 'bg-emerald-50 text-emerald-700'
              : 'bg-slate-100 text-slate-600'
          }`}
        >
          {quiz.is_published ? 'Đã publish' : 'Bản nháp'}
        </span>
      </td>
      <td className="px-3 py-3.5 text-xs text-brand-muted">
        {formatDate(quiz.created_at)}
      </td>
      <td className="px-3 py-3.5">
        <div className="flex justify-end gap-1">
          <Button
            variant="ghost"
            size="sm"
            onClick={onEdit}
            aria-label={`Sửa ${quiz.title}`}
          >
            <Pencil size={15} />
            Sửa
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="text-brand-red hover:bg-red-50 hover:text-brand-red"
            onClick={onDelete}
            aria-label={`Xóa ${quiz.title}`}
            title="Xóa quiz"
          >
            <Trash2 size={16} />
          </Button>
        </div>
      </td>
    </tr>
  );
}
