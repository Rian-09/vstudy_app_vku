import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '../../components/ui/button';
import type {
  DocumentFolder,
  FolderValues,
  MajorOption,
  SubjectOption,
} from './types';

const folderSchema = z.object({
  name: z.string().trim().min(1, 'Vui lòng nhập tên thư mục.'),
  majorId: z.string(),
  subjectId: z.string(),
  semester: z.string(),
  parentFolderId: z.string(),
});

export type FolderEditorMode = 'create' | 'rename' | 'move';

interface FolderEditorDialogProps {
  mode: FolderEditorMode;
  folder?: DocumentFolder | null;
  initialParentId: string | null;
  folders: DocumentFolder[];
  majors: MajorOption[];
  subjects: SubjectOption[];
  isSaving: boolean;
  onClose: () => void;
  onSave: (values: FolderValues) => void;
}

function excludedFolderIds(folderId: string, folders: DocumentFolder[]) {
  const excluded = new Set([folderId]);
  let changed = true;
  while (changed) {
    changed = false;
    for (const folder of folders) {
      if (
        folder.parent_folder_id &&
        excluded.has(folder.parent_folder_id) &&
        !excluded.has(folder.id)
      ) {
        excluded.add(folder.id);
        changed = true;
      }
    }
  }
  return excluded;
}

function folderLabel(folder: DocumentFolder, folders: DocumentFolder[]) {
  const parent = folders.find((item) => item.id === folder.parent_folder_id);
  return parent ? `${parent.name} / ${folder.name}` : folder.name;
}

const titles: Record<FolderEditorMode, string> = {
  create: 'Tạo thư mục',
  rename: 'Đổi tên thư mục',
  move: 'Di chuyển thư mục',
};

export function FolderEditorDialog({
  mode,
  folder,
  initialParentId,
  folders,
  majors,
  subjects,
  isSaving,
  onClose,
  onSave,
}: FolderEditorDialogProps) {
  const excluded = folder ? excludedFolderIds(folder.id, folders) : new Set<string>();
  const initialParent = folders.find((item) => item.id === initialParentId);
  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = useForm<FolderValues>({
    resolver: zodResolver(folderSchema),
    defaultValues: {
      name: folder?.name ?? '',
      majorId: folder?.major_id ?? initialParent?.major_id ?? '',
      subjectId: folder?.subject_id ?? initialParent?.subject_id ?? '',
      semester: folder?.semester ?? '',
      parentFolderId: folder?.parent_folder_id ?? initialParentId ?? '',
    },
  });
  const majorId = watch('majorId');
  const subjectId = watch('subjectId');
  const availableSubjects = subjects.filter(
    (subject) => !majorId || !subject.major_id || subject.major_id === majorId,
  );

  const submit = handleSubmit(async (values) => {
    onSave(values);
  });

  return (
    <div
      className="fixed inset-0 z-30 grid place-items-center bg-slate-950/40 p-4"
      onMouseDown={(event) => {
        if (!isSaving && event.target === event.currentTarget) onClose();
      }}
    >
      <section
        role="dialog"
        aria-modal="true"
        aria-labelledby="folder-editor-title"
        className="w-full max-w-lg rounded-2xl bg-white shadow-2xl"
      >
        <header className="border-b border-slate-100 px-6 py-4">
          <h2
            id="folder-editor-title"
            className="text-lg font-bold text-brand-ink"
          >
            {titles[mode]}
          </h2>
        </header>
        <form className="space-y-4 p-6" onSubmit={submit} noValidate>
          {mode !== 'move' && (
            <>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Tên thư mục
                <input
                  className="h-11 w-full rounded-xl border border-slate-200 px-3 text-sm font-normal outline-none focus:border-brand-blue"
                  {...register('name')}
                  aria-invalid={Boolean(errors.name)}
                />
                {errors.name && (
                  <span className="block text-xs text-brand-red">
                    {errors.name.message}
                  </span>
                )}
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Ngành học
                <select
                  className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
                  {...register('majorId', {
                    onChange: () => setValue('subjectId', ''),
                  })}
                >
                  <option value="">Không gắn ngành</option>
                  {majors.map((major) => (
                    <option key={major.id} value={major.id}>
                      {major.code} · {major.name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Môn học (không bắt buộc)
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
                  <option value="">Không gắn môn học</option>
                  {availableSubjects.map((subject) => (
                    <option key={subject.id} value={subject.id}>
                      {subject.code} · {subject.name}
                    </option>
                  ))}
                </select>
              </label>
              <label className="block space-y-2 text-sm font-semibold text-brand-ink">
                Học kỳ
                <input
                  className="h-11 w-full rounded-xl border border-slate-200 px-3 text-sm font-normal outline-none focus:border-brand-blue"
                  placeholder="Ví dụ: HK1 2026–2027"
                  {...register('semester')}
                />
              </label>
            </>
          )}

          <label className="block space-y-2 text-sm font-semibold text-brand-ink">
            Thư mục cha
            <select
              className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
              {...register('parentFolderId')}
            >
              <option value="">Thư mục gốc</option>
              {folders
                .filter((item) => !excluded.has(item.id))
                .map((item) => (
                  <option key={item.id} value={item.id}>
                    {folderLabel(item, folders)}
                  </option>
                ))}
            </select>
          </label>

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
              {isSaving ? 'Đang lưu...' : mode === 'move' ? 'Di chuyển' : 'Lưu'}
            </Button>
          </footer>
        </form>
      </section>
    </div>
  );
}
