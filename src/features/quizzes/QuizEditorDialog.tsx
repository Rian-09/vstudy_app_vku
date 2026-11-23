import { zodResolver } from '@hookform/resolvers/zod';
import {
  ArrowDown,
  ArrowUp,
  Check,
  Plus,
  Trash2,
  X,
} from 'lucide-react';
import { useState } from 'react';
import {
  useFieldArray,
  useForm,
  useWatch,
} from 'react-hook-form';
import { z } from 'zod';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import type { QuizDraft, QuizSubject } from './types';

const questionSchema = z.object({
  id: z.string().uuid().optional(),
  questionText: z.string().trim().min(1, 'Nhập nội dung câu hỏi.'),
  options: z.tuple([
    z.string().trim().min(1, 'Nhập lựa chọn.'),
    z.string().trim().min(1, 'Nhập lựa chọn.'),
    z.string().trim().min(1, 'Nhập lựa chọn.'),
    z.string().trim().min(1, 'Nhập lựa chọn.'),
  ]),
  correctIndex: z.number().int().min(0).max(3),
  explanation: z.string(),
});

const quizSchema = z
  .object({
    title: z.string().trim().min(1, 'Nhập tiêu đề quiz.'),
    subjectId: z.string().uuid('Chọn môn học.'),
    description: z.string(),
    durationMinutes: z.coerce.number().int().min(1, 'Thời lượng phải lớn hơn 0.'),
    mode: z.enum(['practice', 'exam']),
    shuffleOptions: z.boolean(),
    isPublished: z.boolean(),
    questions: z.array(questionSchema),
  })
  .superRefine((value, context) => {
    if (value.isPublished && value.questions.length === 0) {
      context.addIssue({
        code: 'custom',
        path: ['questions'],
        message: 'Thêm ít nhất một câu hỏi trước khi publish quiz.',
      });
    }
  });

type QuizFormInput = z.input<typeof quizSchema>;
type QuizFormOutput = z.output<typeof quizSchema>;

interface QuizEditorDialogProps {
  quizId: string | null;
  initialQuiz: QuizDraft | null;
  subjects: QuizSubject[];
  isLoading: boolean;
  isSaving: boolean;
  onClose: () => void;
  onSave: (quiz: QuizDraft) => Promise<void>;
}

export function QuizEditorDialog({
  quizId,
  initialQuiz,
  subjects,
  isLoading,
  isSaving,
  onClose,
  onSave,
}: QuizEditorDialogProps) {
  const [selectedQuestions, setSelectedQuestions] = useState<Set<string>>(
    new Set(),
  );
  const {
    control,
    register,
    handleSubmit,
    setValue,
    formState: { errors },
  } = useForm<QuizFormInput, unknown, QuizFormOutput>({
    resolver: zodResolver(quizSchema),
    defaultValues: {
      title: initialQuiz?.title ?? '',
      subjectId: initialQuiz?.subjectId ?? '',
      description: initialQuiz?.description ?? '',
      durationMinutes: initialQuiz?.durationMinutes ?? 30,
      mode: initialQuiz?.mode ?? 'practice',
      shuffleOptions: initialQuiz?.shuffleOptions ?? true,
      isPublished: initialQuiz?.isPublished ?? false,
      questions: initialQuiz?.questions ?? [],
    },
  });
  const {
    fields,
    append,
    move,
    remove,
  } = useFieldArray<QuizFormInput, 'questions', 'fieldKey'>({
    control,
    name: 'questions',
    keyName: 'fieldKey',
  });
  const mode = useWatch({ control, name: 'mode' });
  const isPublished = useWatch({ control, name: 'isPublished' });
  const durationMinutes = useWatch({ control, name: 'durationMinutes' });
  const watchedQuestions = useWatch({ control, name: 'questions' });

  const submit = handleSubmit(async (values) => {
    await onSave(values);
  });

  const deleteSelectedQuestions = () => {
    const indexes = fields
      .map((field, index) =>
        selectedQuestions.has(field.fieldKey) ? index : -1,
      )
      .filter((index) => index >= 0)
      .sort((left, right) => right - left);
    remove(indexes);
    setSelectedQuestions(new Set());
  };

  return (
    <div
      className="fixed inset-0 z-30 grid place-items-center overflow-y-auto bg-slate-950/45 p-2 sm:p-5"
      onMouseDown={(event) => {
        if (!isSaving && event.target === event.currentTarget) onClose();
      }}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="quiz-editor-title"
        className="my-auto flex max-h-[96vh] w-full max-w-5xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl"
      >
        <header className="flex items-center justify-between border-b border-slate-100 px-5 py-4 sm:px-7">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
              {quizId ? 'Chỉnh sửa ngân hàng câu hỏi' : 'Tạo quiz'}
            </p>
            <h2
              id="quiz-editor-title"
              className="mt-1 text-lg font-bold text-brand-ink"
            >
              {quizId ? initialQuiz?.title || 'Đang tải quiz...' : 'Quiz mới'}
            </h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={isSaving}
            aria-label="Đóng"
            className="rounded-lg p-2 text-slate-500 hover:bg-slate-100"
          >
            <X size={20} />
          </button>
        </header>

        {isLoading ? (
          <div className="space-y-4 p-7">
            <div className="h-12 animate-pulse rounded-xl bg-slate-100" />
            <div className="h-40 animate-pulse rounded-xl bg-slate-100" />
          </div>
        ) : (
          <form
            className="flex min-h-0 flex-1 flex-col"
            onSubmit={submit}
            noValidate
          >
            <div className="min-h-0 flex-1 space-y-6 overflow-y-auto p-5 sm:p-7">
              <section className="grid gap-4 rounded-2xl bg-slate-50 p-4 sm:grid-cols-2 sm:p-5">
                <label className="block space-y-2 text-sm font-semibold text-brand-ink sm:col-span-2">
                  Tiêu đề
                  <Input
                    placeholder="Ví dụ: Ôn tập chương 1"
                    aria-invalid={Boolean(errors.title)}
                    {...register('title')}
                  />
                  {errors.title && (
                    <span className="block text-xs text-brand-red">
                      {errors.title.message}
                    </span>
                  )}
                </label>

                <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                  Môn học
                  <select
                    className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                    {...register('subjectId')}
                  >
                    <option value="">Chọn môn học</option>
                    {subjects.map((subject) => (
                      <option key={subject.id} value={subject.id}>
                        {subject.code} · {subject.name}
                      </option>
                    ))}
                  </select>
                  {errors.subjectId && (
                    <span className="block text-xs text-brand-red">
                      {errors.subjectId.message}
                    </span>
                  )}
                </label>

                <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                  Chế độ mặc định
                  <select
                    className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                    {...register('mode')}
                  >
                    <option value="practice">
                      Luyện tập · không giới hạn thời gian
                    </option>
                    <option value="exam">
                      Luyện thi · có đếm ngược
                    </option>
                  </select>
                </label>

                {mode === 'exam' && (
                  <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                    Thời lượng (phút)
                    <Input
                      type="number"
                      min={1}
                      {...register('durationMinutes', { valueAsNumber: true })}
                    />
                    {errors.durationMinutes && (
                      <span className="block text-xs text-brand-red">
                        {errors.durationMinutes.message}
                      </span>
                    )}
                  </label>
                )}

                <label className="block space-y-2 text-sm font-semibold text-brand-ink sm:col-span-2">
                  Mô tả
                  <textarea
                    rows={2}
                    className="w-full resize-y rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-sm font-normal outline-none focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/15"
                    placeholder="Mô tả ngắn về quiz"
                    {...register('description')}
                  />
                </label>

                <label className="flex items-start gap-3 rounded-xl border border-brand-purple/10 bg-white p-3 text-sm sm:col-span-2">
                  <input
                    type="checkbox"
                    className="mt-0.5 h-4 w-4 accent-[#6b5cc7]"
                    {...register('shuffleOptions')}
                  />
                  <span>
                    <span className="block font-semibold text-brand-ink">
                      Trộn thứ tự đáp án mỗi lượt
                    </span>
                    <span className="mt-0.5 block text-xs text-brand-muted">
                      Mỗi sinh viên sẽ thấy lựa chọn theo thứ tự ngẫu nhiên; hệ
                      thống vẫn chấm đúng đáp án.
                    </span>
                  </span>
                </label>

                <label className="flex items-start gap-3 rounded-xl bg-white p-3 text-sm sm:col-span-2">
                  <input
                    type="checkbox"
                    className="mt-0.5 h-4 w-4 accent-[#174a78]"
                    {...register('isPublished')}
                  />
                  <span>
                    <span className="block font-semibold text-brand-ink">
                      Publish cho sinh viên
                    </span>
                    <span className="mt-0.5 block text-xs text-brand-muted">
                      Quiz draft chỉ hiển thị với quản trị viên.
                    </span>
                  </span>
                </label>
                {isPublished && fields.length === 0 && (
                  <p className="text-xs text-brand-red sm:col-span-2">
                    Quiz cần ít nhất một câu hỏi để publish.
                  </p>
                )}
              </section>

              <section>
                <div className="mb-3 flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <h3 className="font-bold text-brand-ink">
                      Câu hỏi ({fields.length})
                    </h3>
                    <p className="mt-1 text-xs text-brand-muted">
                      Mỗi câu có bốn lựa chọn và một đáp án đúng.
                    </p>
                  </div>
                  <div className="flex gap-2">
                    {selectedQuestions.size > 0 && (
                      <Button
                        type="button"
                        variant="outline"
                        size="sm"
                        className="text-brand-red"
                        onClick={deleteSelectedQuestions}
                      >
                        <Trash2 size={15} />
                        Xóa đã chọn ({selectedQuestions.size})
                      </Button>
                    )}
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      onClick={() =>
                        append({
                          questionText: '',
                          options: ['', '', '', ''],
                          correctIndex: 0,
                          explanation: '',
                        })
                      }
                    >
                      <Plus size={15} />
                      Thêm câu hỏi
                    </Button>
                  </div>
                </div>
                {errors.questions?.message && (
                  <p className="mb-3 text-sm text-brand-red">
                    {errors.questions.message}
                  </p>
                )}

                <div className="space-y-4">
                  {fields.map((field, questionIndex) => {
                    const selected = selectedQuestions.has(field.fieldKey);
                    return (
                      <article
                        key={field.fieldKey}
                        className="rounded-2xl border border-slate-200 p-4 sm:p-5"
                      >
                        <div className="mb-4 flex items-center gap-2">
                          <input
                            type="checkbox"
                            aria-label={`Chọn câu ${questionIndex + 1}`}
                            checked={selected}
                            className="h-4 w-4 accent-[#174a78]"
                            onChange={(event) =>
                              setSelectedQuestions((current) => {
                                const next = new Set(current);
                                if (event.target.checked) next.add(field.fieldKey);
                                else next.delete(field.fieldKey);
                                return next;
                              })
                            }
                          />
                          <h4 className="flex-1 text-sm font-bold text-brand-ink">
                            Câu {questionIndex + 1}
                          </h4>
                          <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            aria-label={`Đưa câu ${questionIndex + 1} lên`}
                            disabled={questionIndex === 0}
                            onClick={() => move(questionIndex, questionIndex - 1)}
                          >
                            <ArrowUp size={16} />
                          </Button>
                          <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            aria-label={`Đưa câu ${questionIndex + 1} xuống`}
                            disabled={questionIndex === fields.length - 1}
                            onClick={() => move(questionIndex, questionIndex + 1)}
                          >
                            <ArrowDown size={16} />
                          </Button>
                          <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            className="text-brand-red hover:bg-red-50 hover:text-brand-red"
                            aria-label={`Xóa câu ${questionIndex + 1}`}
                            onClick={() => remove(questionIndex)}
                          >
                            <Trash2 size={16} />
                          </Button>
                        </div>

                        <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                          Nội dung câu hỏi
                          <textarea
                            rows={2}
                            className="w-full resize-y rounded-xl border border-slate-200 px-3.5 py-3 text-sm font-normal outline-none focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/15"
                            {...register(
                              `questions.${questionIndex}.questionText`,
                            )}
                          />
                          {errors.questions?.[questionIndex]?.questionText && (
                            <span className="block text-xs text-brand-red">
                              {
                                errors.questions[questionIndex]?.questionText
                                  ?.message
                              }
                            </span>
                          )}
                        </label>

                        <div className="mt-4 grid gap-3 sm:grid-cols-2">
                          {([0, 1, 2, 3] as const).map((optionIndex) => {
                            const letter = String.fromCharCode(
                              65 + optionIndex,
                            );
                            const optionError =
                              errors.questions?.[questionIndex]?.options?.[
                                optionIndex
                              ];
                            const isCorrect =
                              watchedQuestions?.[questionIndex]
                                ?.correctIndex === optionIndex;
                            return (
                              <div
                                key={letter}
                                className={`grid grid-cols-[auto_auto_minmax(0,1fr)_auto] items-center gap-2 rounded-xl border p-2.5 ${
                                  isCorrect
                                    ? 'border-emerald-300 bg-emerald-50/60'
                                    : 'border-slate-200'
                                }`}
                              >
                                <input
                                  type="radio"
                                  name={`correct-${field.fieldKey}`}
                                  aria-label={`Đáp án ${letter} là đúng`}
                                  checked={isCorrect}
                                  onChange={() =>
                                    setValue(
                                      `questions.${questionIndex}.correctIndex`,
                                      optionIndex,
                                      { shouldDirty: true, shouldValidate: true },
                                    )
                                  }
                                  className="h-4 w-4 accent-emerald-600"
                                />
                                <span className="w-5 text-xs font-bold text-brand-muted">
                                  {letter}
                                </span>
                                <Input
                                  className="h-9"
                                  placeholder={`Lựa chọn ${letter}`}
                                  aria-invalid={Boolean(optionError)}
                                  {...register(
                                    `questions.${questionIndex}.options.${optionIndex}`,
                                  )}
                                />
                                {isCorrect && (
                                  <Check
                                    size={16}
                                    className="shrink-0 text-emerald-700"
                                  />
                                )}
                                {optionError?.message && (
                                  <span className="col-span-4 text-[10px] leading-4 text-brand-red">
                                    {optionError.message}
                                  </span>
                                )}
                              </div>
                            );
                          })}
                        </div>

                        <label className="mt-4 block space-y-2 text-sm font-semibold text-brand-ink">
                          Giải thích (không bắt buộc)
                          <Input
                            placeholder="Giải thích đáp án đúng"
                            {...register(
                              `questions.${questionIndex}.explanation`,
                            )}
                          />
                        </label>
                      </article>
                    );
                  })}
                  {fields.length === 0 && (
                    <div className="rounded-2xl border border-dashed border-slate-300 py-10 text-center text-sm text-brand-muted">
                      Quiz chưa có câu hỏi. Thêm câu hỏi để hoàn thiện nội dung.
                    </div>
                  )}
                </div>
              </section>
            </div>

            <footer className="flex items-center justify-between border-t border-slate-100 bg-white px-5 py-4 sm:px-7">
              <span className="text-xs text-brand-muted">
                {fields.length} câu ·{' '}
                {mode === 'exam'
                  ? `${durationMinutes} phút`
                  : 'Không giới hạn thời gian'}
              </span>
              <div className="flex gap-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={onClose}
                  disabled={isSaving}
                >
                  Hủy
                </Button>
                <Button type="submit" variant="yellow" disabled={isSaving}>
                  {isSaving
                    ? 'Đang lưu...'
                    : isPublished
                      ? 'Lưu & publish'
                      : 'Lưu bản nháp'}
                </Button>
              </div>
            </footer>
          </form>
        )}
      </section>
    </div>
  );
}
