import { zodResolver } from '@hookform/resolvers/zod';
import { FileText, UploadCloud, X } from 'lucide-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import {
  getDocumentFileName,
  isSupportedDocument,
} from './documentService';
import type {
  DocumentFolder,
  DocumentValues,
  StudyDocument,
  MajorOption,
  SubjectOption,
} from './types';

const editorSchema = z.object({
  title: z.string().trim().min(1, 'Vui lòng nhập tiêu đề.'),
  description: z.string(),
  majorId: z.string(),
  subjectId: z.string(),
  category: z.enum(['course', 'exam', 'review']),
  folderId: z.string(),
  tags: z.string(),
  isPublished: z.boolean(),
});

interface DocumentEditorDialogProps {
  document?: StudyDocument | null;
  initialFolderId: string | null;
  folders: DocumentFolder[];
  majors: MajorOption[];
  subjects: SubjectOption[];
  isSaving: boolean;
  onClose: () => void;
  onSave: (values: DocumentValues, files: File[]) => Promise<void>;
}

function stripExtension(fileName: string) {
  return fileName.replace(/\.[^.]+$/, '');
}

function folderLabel(folder: DocumentFolder, folders: DocumentFolder[]) {
  const parent = folders.find((item) => item.id === folder.parent_folder_id);
  return parent ? `${parent.name} / ${folder.name}` : folder.name;
}

export function DocumentEditorDialog({
  document,
  initialFolderId,
  folders,
  majors,
  subjects,
  isSaving,
  onClose,
  onSave,
}: DocumentEditorDialogProps) {
  const [files, setFiles] = useState<File[]>([]);
  const [fileError, setFileError] = useState<string | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const isEditing = Boolean(document);
  const initialTitle = document?.title ?? '';
  const initialFolder = folders.find(
    (folder) => folder.id === (document?.folder_id ?? initialFolderId),
  );
  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = useForm<DocumentValues>({
    resolver: zodResolver(editorSchema),
    defaultValues: {
      title: initialTitle,
      description: document?.description ?? '',
      majorId: document?.major_id ?? initialFolder?.major_id ?? '',
      subjectId: document?.subject_id ?? initialFolder?.subject_id ?? '',
      category: document?.category ?? 'course',
      folderId: document?.folder_id ?? initialFolderId ?? '',
      tags: document?.tags.join(', ') ?? '',
      isPublished: document?.is_published ?? false,
    },
  });
  const majorId = watch('majorId');
  const subjectId = watch('subjectId');
  const folderId = watch('folderId');
  const availableSubjects = subjects.filter(
    (subject) => !majorId || !subject.major_id || subject.major_id === majorId,
  );

  const addFiles = (selected: FileList | File[]) => {
    const incoming = Array.from(selected);
    const invalid = incoming.filter((file) => !isSupportedDocument(file));
    const valid = incoming.filter(isSupportedDocument);
    if (!isEditing && files.length === 0 && valid[0]) {
      setValue('title', stripExtension(valid[0].name), {
        shouldValidate: true,
      });
    }
    setFiles((current) => [...current, ...valid]);
    setFileError(
      invalid.length
        ? `Không hỗ trợ: ${invalid.map((file) => file.name).join(', ')}. Chỉ nhận PDF, DOCX, PPTX, TXT.`
        : null,
    );
  };

  const submit = handleSubmit(async (values) => {
    if (!isEditing && files.length === 0) {
      setFileError('Chọn ít nhất một tệp để tải lên.');
      return;
    }
    await onSave(values, files);
  });

  return (
    <div
      className="fixed inset-0 z-30 grid place-items-center overflow-y-auto bg-slate-950/40 p-4"
      onMouseDown={(event) => {
        if (!isSaving && event.target === event.currentTarget) onClose();
      }}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="document-editor-title"
        className="my-auto w-full max-w-2xl rounded-2xl bg-white shadow-2xl"
      >
        <header className="flex items-center justify-between border-b border-slate-100 px-5 py-4 sm:px-7">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
              {isEditing ? 'Cập nhật metadata' : 'Tải lên học liệu'}
            </p>
            <h2
              id="document-editor-title"
              className="mt-1 text-lg font-bold text-brand-ink"
            >
              {isEditing ? 'Thông tin tài liệu' : 'Thêm tài liệu'}
            </h2>
          </div>
          <button
            type="button"
            className="rounded-lg p-2 text-slate-500 hover:bg-slate-100"
            onClick={onClose}
            disabled={isSaving}
            aria-label="Đóng"
          >
            <X size={20} />
          </button>
        </header>

        <form className="space-y-5 p-5 sm:p-7" onSubmit={submit} noValidate>
          {!isEditing && (
            <div
              className={`rounded-2xl border-2 border-dashed p-5 text-center transition ${
                isDragging
                  ? 'border-brand-blue bg-blue-50'
                  : 'border-slate-200 bg-slate-50/60'
              }`}
              onDragOver={(event) => {
                event.preventDefault();
                setIsDragging(true);
              }}
              onDragLeave={() => setIsDragging(false)}
              onDrop={(event) => {
                event.preventDefault();
                setIsDragging(false);
                addFiles(event.dataTransfer.files);
              }}
            >
              <UploadCloud className="mx-auto text-brand-blue" size={27} />
              <p className="mt-2 text-sm font-semibold text-brand-ink">
                Kéo thả tài liệu vào đây
              </p>
              <p className="mt-1 text-xs text-brand-muted">
                PDF, DOCX, PPTX hoặc TXT; có thể chọn nhiều tệp.
              </p>
              <label className="mt-3 inline-flex cursor-pointer items-center rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-brand-blue hover:bg-slate-50">
                Chọn tệp
                <input
                  type="file"
                  className="sr-only"
                  multiple
                  accept=".pdf,.docx,.pptx,.txt"
                  onChange={(event) => {
                    if (event.target.files) addFiles(event.target.files);
                    event.target.value = '';
                  }}
                />
              </label>
              {files.length > 0 && (
                <ul className="mt-4 space-y-2 text-left">
                  {files.map((file, index) => (
                    <li
                      key={`${file.name}-${file.size}-${index}`}
                      className="flex items-center gap-2 rounded-lg bg-white px-3 py-2 text-xs text-brand-ink"
                    >
                      <FileText size={15} className="shrink-0 text-brand-blue" />
                      <span className="min-w-0 flex-1 truncate">{file.name}</span>
                      <span className="shrink-0 text-brand-muted">
                        {(file.size / 1024 / 1024).toFixed(1)} MB
                      </span>
                      <button
                        type="button"
                        aria-label={`Bỏ ${file.name}`}
                        className="rounded p-1 text-slate-400 hover:bg-red-50 hover:text-brand-red"
                        onClick={() =>
                          setFiles((current) =>
                            current.filter((_, fileIndex) => fileIndex !== index),
                          )
                        }
                      >
                        <X size={14} />
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )}

          {isEditing && document && (
            <div className="flex items-center gap-3 rounded-xl bg-slate-50 p-3 text-sm text-brand-ink">
              <FileText size={18} className="shrink-0 text-brand-blue" />
              <span className="truncate">{getDocumentFileName(document)}</span>
              <span className="ml-auto shrink-0 text-xs uppercase text-brand-muted">
                {document.file_type}
              </span>
            </div>
          )}

          <label className="block space-y-2 text-sm font-semibold text-brand-ink">
            Tiêu đề
            <Input
              placeholder="Tên tài liệu"
              {...register('title')}
              aria-invalid={Boolean(errors.title)}
            />
            {errors.title && (
              <span className="block text-xs font-medium text-brand-red">
                {errors.title.message}
              </span>
            )}
            {!isEditing && files.length > 1 && (
              <span className="block text-xs font-normal text-brand-muted">
                Mỗi tệp sẽ dùng tên file làm tiêu đề.
              </span>
            )}
          </label>

          <div className="grid gap-4 sm:grid-cols-2">
            <label className="block space-y-2 text-sm font-semibold text-brand-ink">
              Ngành học
              <select
                className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                {...register('majorId', {
                  onChange: () => setValue('subjectId', ''),
                })}
              >
                <option value="">Chưa phân loại</option>
                {majors.map((major) => (
                  <option key={major.id} value={major.id}>
                    {major.code} · {major.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="block space-y-2 text-sm font-semibold text-brand-ink">
              Môn học
              <select
                className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                value={subjectId}
                onChange={(event) => {
                  const selectedSubject = subjects.find(
                    (subject) => subject.id === event.target.value,
                  );
                  setValue('subjectId', event.target.value);
                  if (selectedSubject?.major_id) {
                    setValue('majorId', selectedSubject.major_id);
                  }
                }}
              >
                <option value="">Chưa phân loại</option>
                {availableSubjects.map((subject) => (
                  <option key={subject.id} value={subject.id}>
                    {subject.code} · {subject.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="block space-y-2 text-sm font-semibold text-brand-ink">
              Loại tài liệu
              <select
                className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                {...register('category')}
              >
                <option value="course">Tài liệu môn học</option>
                <option value="exam">Đề thi</option>
                <option value="review">Ôn tập</option>
              </select>
            </label>
          </div>

          <label className="block space-y-2 text-sm font-semibold text-brand-ink">
            Thư mục
            <select
              className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
              value={folderId}
              onChange={(event) => {
                const selectedFolder = folders.find(
                  (folder) => folder.id === event.target.value,
                );
                setValue('folderId', event.target.value);
                if (selectedFolder) {
                  setValue('majorId', selectedFolder.major_id ?? '');
                  setValue('subjectId', selectedFolder.subject_id ?? '');
                }
              }}
            >
              <option value="">Không thuộc thư mục</option>
              {folders.map((folder) => (
                <option key={folder.id} value={folder.id}>
                  {folderLabel(folder, folders)}
                </option>
              ))}
            </select>
          </label>

          <label className="block space-y-2 text-sm font-semibold text-brand-ink">
            Mô tả
            <textarea
              rows={3}
              className="w-full resize-y rounded-xl border border-slate-200 bg-white px-3.5 py-3 text-sm font-normal outline-none placeholder:text-slate-400 focus:border-brand-blue focus:ring-2 focus:ring-brand-blue/15"
              placeholder="Mô tả ngắn về tài liệu"
              {...register('description')}
            />
          </label>

          <label className="block space-y-2 text-sm font-semibold text-brand-ink">
            Tags
            <Input placeholder="ví dụ: chương 1, đề cương, 2026" {...register('tags')} />
            <span className="block text-xs font-normal text-brand-muted">
              Phân tách tags bằng dấu phẩy.
            </span>
          </label>

          <label className="flex items-start gap-3 rounded-xl bg-slate-50 p-3 text-sm text-brand-ink">
            <input
              type="checkbox"
              className="mt-0.5 h-4 w-4 accent-[#174a78]"
              {...register('isPublished')}
            />
            <span>
              <span className="block font-semibold">Hiển thị cho sinh viên</span>
              <span className="mt-0.5 block text-xs text-brand-muted">
                Tài liệu chưa publish chỉ quản trị viên xem được.
              </span>
            </span>
          </label>

          {fileError && (
            <p role="alert" className="text-sm text-brand-red">
              {fileError}
            </p>
          )}

          <footer className="flex justify-end gap-2 border-t border-slate-100 pt-4">
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
                : isEditing
                  ? 'Lưu thay đổi'
                  : `Tải lên (${files.length})`}
            </Button>
          </footer>
        </form>
      </section>
    </div>
  );
}
