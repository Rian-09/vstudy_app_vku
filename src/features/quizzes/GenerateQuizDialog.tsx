import {
  ArrowLeft,
  Check,
  FileText,
  RefreshCw,
  Sparkles,
  Trash2,
  UploadCloud,
  X,
} from 'lucide-react';
import { useState } from 'react';
import { toast } from 'sonner';
import { z } from 'zod';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import {
  getDocumentExtension,
  isSupportedDocument,
  uploadDocument,
} from '../documents/documentService';
import type {
  DocumentValues,
  StudyDocument,
} from '../documents/types';
import {
  generateQuizQuestions,
  type GeneratedQuestion,
} from './generateQuizService';
import type { QuizDraft, QuizSubject } from './types';

const previewSchema = z.object({
  title: z.string().trim().min(1, 'Nhập tiêu đề quiz.'),
  questions: z.array(
    z.object({
      question: z.string().trim().min(1, 'Nhập nội dung câu hỏi.'),
      options: z.tuple([
        z.string().trim().min(1, 'Nhập đủ bốn lựa chọn.'),
        z.string().trim().min(1, 'Nhập đủ bốn lựa chọn.'),
        z.string().trim().min(1, 'Nhập đủ bốn lựa chọn.'),
        z.string().trim().min(1, 'Nhập đủ bốn lựa chọn.'),
      ]),
      correctIndex: z.number().int().min(0).max(3),
      explanation: z.string(),
    }),
  ).min(1, 'Quiz cần ít nhất một câu hỏi.'),
});

type GenerationConfig = {
  documentId: string;
  documentTitle: string;
  subjectId: string;
  questionCount: number;
  durationMinutes: number;
  mode: 'practice' | 'exam';
  difficulty: 'easy' | 'medium' | 'hard' | '';
};

interface GenerateQuizDialogProps {
  documents: StudyDocument[];
  subjects: QuizSubject[];
  documentsLoading: boolean;
  documentsError: unknown;
  onClose: () => void;
  onDocumentUploaded: () => void;
  onSave: (quiz: QuizDraft) => Promise<void>;
}

function errorText(error: unknown) {
  return error instanceof Error ? error.message : 'Vui lòng thử lại.';
}

function fileTitle(name: string) {
  return name.replace(/\.[^.]+$/, '');
}

export function GenerateQuizDialog({
  documents,
  subjects,
  documentsLoading,
  documentsError,
  onClose,
  onDocumentUploaded,
  onSave,
}: GenerateQuizDialogProps) {
  const [documentId, setDocumentId] = useState('');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [uploadedDocumentId, setUploadedDocumentId] = useState('');
  const [subjectId, setSubjectId] = useState('');
  const [questionCount, setQuestionCount] = useState(10);
  const [durationMinutes, setDurationMinutes] = useState(30);
  const [mode, setMode] = useState<'practice' | 'exam'>('practice');
  const [shuffleOptions, setShuffleOptions] = useState(true);
  const [difficulty, setDifficulty] = useState<
    'easy' | 'medium' | 'hard' | ''
  >('');
  const [questions, setQuestions] = useState<GeneratedQuestion[] | null>(null);
  const [title, setTitle] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);
  const [regeneratingIndex, setRegeneratingIndex] = useState<number | null>(
    null,
  );
  const [isSaving, setIsSaving] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [fileError, setFileError] = useState('');
  const [fieldError, setFieldError] = useState('');

  const availableDocuments = documents.filter((document) =>
    ['pdf', 'docx', 'pptx', 'txt'].includes(getDocumentExtension(document)),
  );
  const currentDocument =
    documents.find((document) => document.id === documentId) ?? null;
  const currentDocumentTitle = selectedFile
    ? fileTitle(selectedFile.name)
    : currentDocument?.title ?? 'Tài liệu đã chọn';

  const selectDocument = (id: string) => {
    setDocumentId(id);
    setSelectedFile(null);
    setUploadedDocumentId('');
    setFileError('');
    const document = documents.find((item) => item.id === id);
    setSubjectId(document?.subject_id ?? '');
  };

  const selectFile = (file: File | undefined) => {
    if (!file) return;
    if (!isSupportedDocument(file)) {
      setFileError('Chỉ nhận file PDF, DOCX, PPTX hoặc TXT.');
      return;
    }
    if (file.size > 15 * 1024 * 1024) {
      setFileError('Tệp vượt giới hạn 15 MB.');
      return;
    }
    setSelectedFile(file);
    setDocumentId('');
    setUploadedDocumentId('');
    setFileError('');
    setSubjectId('');
    setTitle(`${fileTitle(file.name)} - Quiz`);
  };

  const ensureDocumentId = async () => {
    if (uploadedDocumentId) return uploadedDocumentId;
    if (!selectedFile) return documentId;

    const values: DocumentValues = {
      title: fileTitle(selectedFile.name),
      description: 'Tài liệu được tải lên khi tạo quiz bằng AI.',
      majorId: subjects.find((subject) => subject.id === subjectId)?.major_id ?? '',
      subjectId,
      category: 'course',
      folderId: '',
      tags: '',
      isPublished: false,
    };
    const document = await uploadDocument(
      selectedFile,
      values,
      values.title,
    );
    setUploadedDocumentId(document.id);
    onDocumentUploaded();
    return document.id;
  };

  const createConfig = async (): Promise<GenerationConfig | null> => {
    if (!selectedFile && !documentId) {
      setFieldError('Chọn tài liệu hoặc tải lên một tệp.');
      return null;
    }
    if (!subjectId) {
      setFieldError('Chọn môn học cho quiz.');
      return null;
    }
    if (!Number.isInteger(questionCount) || questionCount < 1 || questionCount > 50) {
      setFieldError('Số câu hỏi phải từ 1 đến 50.');
      return null;
    }
    if (!Number.isInteger(durationMinutes) || durationMinutes < 1 || durationMinutes > 600) {
      setFieldError('Thời lượng phải từ 1 đến 600 phút.');
      return null;
    }
    setFieldError('');
    setIsUploading(Boolean(selectedFile && !uploadedDocumentId));
    try {
      const id = await ensureDocumentId();
      if (!id) throw new Error('Không xác định được tài liệu nguồn.');
      return {
        documentId: id,
        documentTitle: currentDocumentTitle,
        subjectId,
        questionCount,
        durationMinutes,
        mode,
        difficulty,
      };
    } finally {
      setIsUploading(false);
    }
  };

  const generate = async (config: GenerationConfig) =>
    generateQuizQuestions({
      documentId: config.documentId,
      subjectId: config.subjectId,
      questionCount: config.questionCount,
      durationMinutes: config.durationMinutes,
      mode: config.mode,
      difficulty: config.difficulty,
    });

  const handleGenerate = async () => {
    setIsGenerating(true);
    try {
      const config = await createConfig();
      if (!config) return;
      const generated = await generate(config);
      setQuestions(generated);
      setTitle((current) =>
        current.trim() ? current : `${config.documentTitle} - Quiz`,
      );
    } catch (error) {
      toast.error(`Không tạo được quiz: ${errorText(error)}`);
    } finally {
      setIsGenerating(false);
    }
  };

  const handleRegenerateAll = async () => {
    const config = await createConfig();
    if (!config) return;
    setIsGenerating(true);
    try {
      setQuestions(await generate(config));
    } catch (error) {
      toast.error(`Không tạo lại được quiz: ${errorText(error)}`);
    } finally {
      setIsGenerating(false);
    }
  };

  const handleRegenerateQuestion = async (index: number) => {
    const config = await createConfig();
    if (!config) return;
    setRegeneratingIndex(index);
    try {
      const [replacement] = await generate({ ...config, questionCount: 1 });
      setQuestions((current) =>
        current?.map((question, questionIndex) =>
          questionIndex === index ? replacement : question,
        ) ?? null,
      );
    } catch (error) {
      toast.error(`Không tạo lại được câu hỏi: ${errorText(error)}`);
    } finally {
      setRegeneratingIndex(null);
    }
  };

  const updateQuestion = (
    questionIndex: number,
    update: (question: GeneratedQuestion) => GeneratedQuestion,
  ) => {
    setQuestions((current) =>
      current?.map((question, index) =>
        index === questionIndex ? update(question) : question,
      ) ?? null,
    );
  };

  const handleSave = async (isPublished: boolean) => {
    if (!questions) return;
    const parsed = previewSchema.safeParse({ title, questions });
    if (!parsed.success) {
      setFieldError(parsed.error.issues[0]?.message ?? 'Kiểm tra lại nội dung quiz.');
      return;
    }
    if (!subjectId) {
      setFieldError('Chọn môn học cho quiz.');
      return;
    }

    const quiz: QuizDraft = {
      title: parsed.data.title,
      subjectId,
      description: `Tạo từ tài liệu: ${currentDocumentTitle}`,
      durationMinutes,
      mode,
      shuffleOptions,
      isPublished,
      questions: parsed.data.questions.map((question) => ({
        questionText: question.question,
        options: question.options,
        correctIndex: question.correctIndex,
        explanation: question.explanation,
      })),
    };
    setIsSaving(true);
    setFieldError('');
    try {
      await onSave(quiz);
      onClose();
    } catch (error) {
      toast.error(`Không lưu được quiz: ${errorText(error)}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-30 grid place-items-center overflow-y-auto bg-slate-950/45 p-2 sm:p-5"
      onMouseDown={(event) => {
        if (
          !isGenerating &&
          !isSaving &&
          event.target === event.currentTarget
        ) {
          onClose();
        }
      }}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="generate-quiz-title"
        className="my-auto flex max-h-[96vh] w-full max-w-5xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl"
      >
        <header className="flex items-center justify-between border-b border-slate-100 px-5 py-4 sm:px-7">
          <div className="flex items-center gap-3">
            {questions && (
              <Button
                type="button"
                variant="ghost"
                size="icon"
                aria-label="Quay lại cấu hình"
                disabled={isSaving}
                onClick={() => setQuestions(null)}
              >
                <ArrowLeft size={18} />
              </Button>
            )}
            <div>
              <p className="flex items-center gap-1 text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
                <Sparkles size={13} />
                Tạo quiz bằng AI
              </p>
              <h2
                id="generate-quiz-title"
                className="mt-1 text-lg font-bold text-brand-ink"
              >
                {questions ? 'Xem trước và chỉnh sửa' : 'Chọn tài liệu nguồn'}
              </h2>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={isGenerating || isSaving}
            aria-label="Đóng"
            className="rounded-lg p-2 text-slate-500 hover:bg-slate-100"
          >
            <X size={20} />
          </button>
        </header>

        {!questions ? (
          <div className="min-h-0 flex-1 space-y-5 overflow-y-auto p-5 sm:p-7">
            {Boolean(documentsError) && (
              <p role="alert" className="rounded-xl bg-red-50 p-3 text-sm text-brand-red">
                Không tải được tài liệu hoặc môn học. {errorText(documentsError)}
              </p>
            )}

            <label className="block space-y-2 text-sm font-semibold text-brand-ink">
              Tài liệu đã có
              <select
                value={documentId}
                disabled={documentsLoading || Boolean(selectedFile)}
                onChange={(event) => selectDocument(event.target.value)}
                className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
              >
                <option value="">
                  {documentsLoading ? 'Đang tải tài liệu...' : 'Chọn tài liệu PDF, DOCX, PPTX hoặc TXT'}
                </option>
                {availableDocuments.map((document) => (
                  <option key={document.id} value={document.id}>
                    {document.title} · {getDocumentExtension(document).toUpperCase()}
                  </option>
                ))}
              </select>
            </label>

            <div className="flex items-center gap-3 text-xs font-semibold uppercase tracking-wide text-brand-muted">
              <span className="h-px flex-1 bg-slate-200" />
              Hoặc tải tài liệu mới
              <span className="h-px flex-1 bg-slate-200" />
            </div>

            <label className="flex cursor-pointer flex-col items-center rounded-2xl border-2 border-dashed border-slate-200 bg-slate-50 p-6 text-center hover:border-brand-blue">
              <UploadCloud size={24} className="text-brand-blue" />
              <span className="mt-2 text-sm font-semibold text-brand-ink">
                {selectedFile ? selectedFile.name : 'Chọn PDF, DOCX, PPTX hoặc TXT'}
              </span>
              <span className="mt-1 text-xs text-brand-muted">
                Tối đa 15 MB. Tệp mới sẽ được lưu vào Quản lý tài liệu.
              </span>
              <input
                type="file"
                className="sr-only"
                accept=".pdf,.docx,.pptx,.txt"
                disabled={isUploading || isGenerating}
                onChange={(event) => {
                  selectFile(event.target.files?.[0]);
                  event.target.value = '';
                }}
              />
            </label>
            {selectedFile && (
              <div className="flex items-center gap-2 rounded-xl bg-blue-50 px-3 py-2 text-sm text-brand-blue">
                <FileText size={16} />
                <span className="min-w-0 flex-1 truncate">{selectedFile.name}</span>
                <button
                  type="button"
                  aria-label="Bỏ tệp đã chọn"
                  className="rounded p-1 hover:bg-blue-100"
                  onClick={() => {
                    setSelectedFile(null);
                    setUploadedDocumentId('');
                    setFileError('');
                  }}
                >
                  <X size={15} />
                </button>
              </div>
            )}
            {fileError && <p role="alert" className="text-xs text-brand-red">{fileError}</p>}

            <div className="grid gap-4 sm:grid-cols-2">
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Môn học
                <select
                  value={subjectId}
                  onChange={(event) => setSubjectId(event.target.value)}
                  className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                >
                  <option value="">Chọn môn học</option>
                  {subjects.map((subject) => (
                    <option key={subject.id} value={subject.id}>
                      {subject.code} · {subject.name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Số câu hỏi (1–50)
                <Input
                  type="number"
                  min={1}
                  max={50}
                  value={questionCount}
                  onChange={(event) => setQuestionCount(Number(event.target.value))}
                />
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Chế độ
                <select
                  value={mode}
                  onChange={(event) =>
                    setMode(event.target.value as 'practice' | 'exam')
                  }
                  className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                >
                  <option value="practice">Luyện tập · không giới hạn thời gian</option>
                  <option value="exam">Luyện thi · có đếm ngược</option>
                </select>
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Thời lượng (phút)
                <Input
                  type="number"
                  min={1}
                  max={600}
                  value={durationMinutes}
                  onChange={(event) => setDurationMinutes(Number(event.target.value))}
                />
                {mode === 'practice' && (
                  <span className="block text-xs font-normal text-brand-muted">
                    Chỉ dùng khi chọn chế độ luyện thi.
                  </span>
                )}
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink sm:col-span-2">
                Độ khó (không bắt buộc)
                <select
                  value={difficulty}
                  onChange={(event) =>
                    setDifficulty(
                      event.target.value as 'easy' | 'medium' | 'hard' | '',
                    )
                  }
                  className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                >
                  <option value="">Tự chọn theo tài liệu</option>
                  <option value="easy">Cơ bản</option>
                  <option value="medium">Trung bình</option>
                  <option value="hard">Nâng cao</option>
                </select>
              </label>
              <label className="flex items-start gap-3 rounded-xl border border-brand-purple/10 bg-brand-lavender/40 p-3 text-sm sm:col-span-2">
                <input
                  type="checkbox"
                  checked={shuffleOptions}
                  onChange={(event) => setShuffleOptions(event.target.checked)}
                  className="mt-0.5 h-4 w-4 accent-[#6b5cc7]"
                />
                <span>
                  <span className="block font-semibold text-brand-ink">
                    Trộn thứ tự đáp án mỗi lượt
                  </span>
                  <span className="mt-0.5 block text-xs font-normal text-brand-muted">
                    Đáp án đúng không cố định ở cùng một vị trí cho mọi sinh viên.
                  </span>
                </span>
              </label>
            </div>

            {fieldError && <p role="alert" className="text-sm text-brand-red">{fieldError}</p>}
            <div className="flex justify-end gap-2 border-t border-slate-100 pt-4">
              <Button
                type="button"
                variant="outline"
                disabled={isGenerating || isUploading}
                onClick={onClose}
              >
                Hủy
              </Button>
              <Button
                type="button"
                variant="yellow"
                disabled={isGenerating || isUploading}
                onClick={() => void handleGenerate()}
              >
                <Sparkles size={16} />
                {isGenerating || isUploading
                  ? 'Đang tạo câu hỏi...'
                  : 'Tạo câu hỏi'}
              </Button>
            </div>
            {isGenerating && (
              <p role="status" className="text-center text-sm text-brand-muted">
                AI đang đọc tài liệu và tạo câu hỏi. Tệp lớn có thể mất thêm thời gian.
              </p>
            )}
          </div>
        ) : (
          <div className="min-h-0 flex-1 space-y-5 overflow-y-auto p-5 sm:p-7">
            <div className="grid gap-4 rounded-2xl bg-slate-50 p-4 sm:grid-cols-2">
              <label className="block space-y-2 text-sm font-semibold text-brand-ink sm:col-span-2">
                Tiêu đề quiz
                <Input
                  value={title}
                  aria-invalid={!title.trim()}
                  onChange={(event) => setTitle(event.target.value)}
                />
              </label>
              <p className="text-xs text-brand-muted">
                {subjects.find((subject) => subject.id === subjectId)?.name}
              </p>
              <p className="text-xs text-brand-muted">
                {mode === 'exam' ? `Luyện thi · ${durationMinutes} phút` : 'Luyện tập · không giới hạn thời gian'}
              </p>
              <p className="text-xs font-medium text-brand-purple">
                {shuffleOptions ? 'Đã bật trộn đáp án mỗi lượt' : 'Không trộn đáp án'}
              </p>
            </div>

            <div className="flex flex-wrap items-center justify-between gap-3">
              <div>
                <h3 className="font-bold text-brand-ink">
                  Xem trước · {questions.length} câu
                </h3>
                <p className="mt-1 text-xs text-brand-muted">
                  Chỉnh sửa nội dung, đáp án và giải thích trước khi lưu.
                </p>
              </div>
              <Button
                type="button"
                variant="outline"
                size="sm"
                disabled={isGenerating || isSaving}
                onClick={() => void handleRegenerateAll()}
              >
                <RefreshCw size={15} />
                Tạo lại tất cả
              </Button>
            </div>

            {questions.map((question, questionIndex) => (
              <article
                key={questionIndex}
                className="rounded-2xl border border-slate-200 p-4 sm:p-5"
              >
                <div className="mb-3 flex items-center gap-2">
                  <h4 className="flex-1 text-sm font-bold text-brand-ink">
                    Câu {questionIndex + 1}
                  </h4>
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    disabled={isGenerating || isSaving || regeneratingIndex !== null}
                    onClick={() => void handleRegenerateQuestion(questionIndex)}
                  >
                    <RefreshCw size={14} />
                    {regeneratingIndex === questionIndex ? 'Đang tạo...' : 'Tạo lại'}
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    aria-label={`Xóa câu ${questionIndex + 1}`}
                    disabled={isSaving}
                    className="text-brand-red hover:bg-red-50 hover:text-brand-red"
                    onClick={() =>
                      setQuestions((current) =>
                        current?.filter((_, index) => index !== questionIndex) ?? null,
                      )
                    }
                  >
                    <Trash2 size={16} />
                  </Button>
                </div>
                <textarea
                  rows={2}
                  aria-label={`Nội dung câu ${questionIndex + 1}`}
                  className="w-full resize-y rounded-xl border border-slate-200 px-3.5 py-3 text-sm outline-none focus:border-brand-blue"
                  value={question.question}
                  onChange={(event) =>
                    updateQuestion(questionIndex, (current) => ({
                      ...current,
                      question: event.target.value,
                    }))
                  }
                />
                <div className="mt-3 grid gap-2 sm:grid-cols-2">
                  {question.options.map((option, optionIndex) => {
                    const letter = String.fromCharCode(65 + optionIndex);
                    const isCorrect = question.correctIndex === optionIndex;
                    return (
                      <div
                        key={letter}
                        className={`grid grid-cols-[auto_auto_minmax(0,1fr)_auto] items-center gap-2 rounded-xl border p-2 ${
                          isCorrect
                            ? 'border-emerald-300 bg-emerald-50/60'
                            : 'border-slate-200'
                        }`}
                      >
                        <input
                          type="radio"
                          name={`ai-correct-${questionIndex}`}
                          checked={isCorrect}
                          aria-label={`Đáp án ${letter} là đúng`}
                          onChange={() =>
                            updateQuestion(questionIndex, (current) => ({
                              ...current,
                              correctIndex: optionIndex,
                            }))
                          }
                          className="h-4 w-4 accent-emerald-600"
                        />
                        <span className="text-xs font-bold text-brand-muted">
                          {letter}
                        </span>
                        <Input
                          className="h-9"
                          aria-label={`Lựa chọn ${letter} câu ${questionIndex + 1}`}
                          value={option}
                          onChange={(event) =>
                            updateQuestion(questionIndex, (current) => {
                              const options = [...current.options] as [
                                string,
                                string,
                                string,
                                string,
                              ];
                              options[optionIndex] = event.target.value;
                              return { ...current, options };
                            })
                          }
                        />
                        {isCorrect && (
                          <Check size={15} className="text-emerald-700" />
                        )}
                      </div>
                    );
                  })}
                </div>
                <label className="mt-3 block space-y-2 text-sm font-semibold text-brand-ink">
                  Giải thích (không bắt buộc)
                  <textarea
                    rows={2}
                    className="w-full resize-y rounded-xl border border-slate-200 px-3.5 py-3 text-sm font-normal outline-none focus:border-brand-blue"
                    value={question.explanation}
                    onChange={(event) =>
                      updateQuestion(questionIndex, (current) => ({
                        ...current,
                        explanation: event.target.value,
                      }))
                    }
                  />
                </label>
              </article>
            ))}

            {fieldError && <p role="alert" className="text-sm text-brand-red">{fieldError}</p>}
            <div className="flex flex-wrap justify-between gap-2 border-t border-slate-100 pt-4">
              <Button
                type="button"
                variant="outline"
                disabled={isSaving}
                onClick={() => setQuestions(null)}
              >
                <ArrowLeft size={15} />
                Sửa cấu hình
              </Button>
              <div className="flex gap-2">
                <Button
                  type="button"
                  variant="outline"
                  disabled={isSaving}
                  onClick={() => void handleSave(false)}
                >
                  {isSaving ? 'Đang lưu...' : 'Lưu bản nháp'}
                </Button>
                <Button
                  type="button"
                  variant="yellow"
                  disabled={isSaving}
                  onClick={() => void handleSave(true)}
                >
                  {isSaving ? 'Đang lưu...' : 'Lưu & publish'}
                </Button>
              </div>
            </div>
          </div>
        )}
      </section>
    </div>
  );
}
