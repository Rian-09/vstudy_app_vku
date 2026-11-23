import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '../../components/ui/button';
import type { DocumentFolder, StudyDocument } from './types';

const moveSchema = z.object({ folderId: z.string() });
type MoveValues = z.infer<typeof moveSchema>;

interface MoveDocumentDialogProps {
  document: StudyDocument;
  folders: DocumentFolder[];
  isSaving: boolean;
  onClose: () => void;
  onMove: (folderId: string) => void;
}

export function MoveDocumentDialog({
  document,
  folders,
  isSaving,
  onClose,
  onMove,
}: MoveDocumentDialogProps) {
  const { register, handleSubmit } = useForm<MoveValues>({
    resolver: zodResolver(moveSchema),
    defaultValues: { folderId: document.folder_id ?? '' },
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
        aria-labelledby="move-document-title"
        className="w-full max-w-md rounded-2xl bg-white shadow-2xl"
      >
        <form
          className="space-y-5 p-6"
          onSubmit={handleSubmit(({ folderId }) => onMove(folderId))}
        >
          <div>
            <h2
              id="move-document-title"
              className="text-lg font-bold text-brand-ink"
            >
              Di chuyển tài liệu
            </h2>
            <p className="mt-1 truncate text-sm text-brand-muted">
              {document.title}
            </p>
          </div>
          <label className="block space-y-2 text-sm font-semibold text-brand-ink">
            Thư mục đích
            <select
              className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm font-normal outline-none focus:border-brand-blue"
              {...register('folderId')}
            >
              <option value="">Không thuộc thư mục</option>
              {folders.map((folder) => (
                <option key={folder.id} value={folder.id}>
                  {folder.name}
                </option>
              ))}
            </select>
          </label>
          <footer className="flex justify-end gap-2">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={isSaving}
            >
              Hủy
            </Button>
            <Button type="submit" variant="yellow" disabled={isSaving}>
              {isSaving ? 'Đang lưu...' : 'Di chuyển'}
            </Button>
          </footer>
        </form>
      </section>
    </div>
  );
}
