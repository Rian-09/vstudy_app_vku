import { Folder, FolderInput, FolderPen, FolderPlus, Trash2 } from 'lucide-react';
import { Button } from '../../components/ui/button';
import type { DocumentFolder } from './types';

interface FolderTreeProps {
  folders: DocumentFolder[];
  selectedFolderId: string | null;
  onSelect: (folderId: string | null) => void;
  onCreate: (parentFolderId: string | null) => void;
  onRename: (folder: DocumentFolder) => void;
  onMove: (folder: DocumentFolder) => void;
  onDelete: (folder: DocumentFolder) => void;
}

export function FolderTree({
  folders,
  selectedFolderId,
  onSelect,
  onCreate,
  onRename,
  onMove,
  onDelete,
}: FolderTreeProps) {
  const renderFolders = (
    parentId: string | null,
    depth: number,
    ancestors: Set<string>,
  ): React.ReactNode =>
    folders
      .filter((folder) => folder.parent_folder_id === parentId)
      .map((folder) => {
        const hasCycle = ancestors.has(folder.id);
        const nextAncestors = new Set(ancestors).add(folder.id);
        return (
          <div key={folder.id}>
            <div className="group flex items-center gap-1">
              <button
                type="button"
                onClick={() => onSelect(folder.id)}
                className={`flex min-w-0 flex-1 items-center gap-2 rounded-lg py-2 pr-1 text-left text-sm ${
                  selectedFolderId === folder.id
                    ? 'bg-brand-yellow/25 font-semibold text-brand-blue'
                    : 'text-slate-600 hover:bg-slate-50'
                }`}
                style={{ paddingLeft: `${12 + depth * 16}px` }}
                aria-current={selectedFolderId === folder.id ? 'page' : undefined}
              >
                <Folder size={16} className="shrink-0" />
                <span className="min-w-0">
                  <span className="block truncate">{folder.name}</span>
                  {folder.major_name && (
                    <span className="block truncate text-[10px] font-normal text-brand-muted">
                      {folder.major_name}
                    </span>
                  )}
                </span>
              </button>
              <div className="flex shrink-0 opacity-100 sm:opacity-0 sm:group-hover:opacity-100">
                <button
                  type="button"
                  title="Thêm thư mục con"
                  aria-label={`Thêm thư mục con trong ${folder.name}`}
                  className="rounded-md p-1.5 text-slate-400 hover:bg-slate-100 hover:text-brand-blue"
                  onClick={() => onCreate(folder.id)}
                >
                  <FolderPlus size={14} />
                </button>
                <button
                  type="button"
                  title="Đổi tên"
                  aria-label={`Đổi tên thư mục ${folder.name}`}
                  className="rounded-md p-1.5 text-slate-400 hover:bg-slate-100 hover:text-brand-blue"
                  onClick={() => onRename(folder)}
                >
                  <FolderPen size={14} />
                </button>
                <button
                  type="button"
                  title="Di chuyển"
                  aria-label={`Di chuyển thư mục ${folder.name}`}
                  className="rounded-md p-1.5 text-slate-400 hover:bg-slate-100 hover:text-brand-blue"
                  onClick={() => onMove(folder)}
                >
                  <FolderInput size={14} />
                </button>
                <button
                  type="button"
                  title="Xóa thư mục rỗng"
                  aria-label={`Xóa thư mục ${folder.name}`}
                  className="rounded-md p-1.5 text-slate-400 hover:bg-red-50 hover:text-brand-red"
                  onClick={() => onDelete(folder)}
                >
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
            {!hasCycle &&
              renderFolders(folder.id, depth + 1, nextAncestors)}
          </div>
        );
      });

  return (
    <section className="rounded-2xl border border-slate-100 bg-white p-3 shadow-sm">
      <header className="flex items-center justify-between px-2 py-2">
        <h2 className="text-sm font-bold text-brand-ink">Thư mục</h2>
        <Button
          variant="ghost"
          size="icon"
          aria-label="Tạo thư mục"
          title="Tạo thư mục"
          onClick={() => onCreate(null)}
        >
          <FolderPlus size={17} />
        </Button>
      </header>
      <button
        type="button"
        onClick={() => onSelect(null)}
        className={`flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm ${
          selectedFolderId === null
            ? 'bg-brand-yellow/25 font-semibold text-brand-blue'
            : 'text-slate-600 hover:bg-slate-50'
        }`}
        aria-current={selectedFolderId === null ? 'page' : undefined}
      >
        <Folder size={16} />
        Tất cả tài liệu
      </button>
      <div className="mt-1 max-h-[58vh] overflow-y-auto">
        {renderFolders(null, 0, new Set())}
      </div>
      {folders.length === 0 && (
        <p className="px-3 py-4 text-xs leading-5 text-brand-muted">
          Chưa có thư mục. Tạo thư mục theo môn học hoặc học kỳ.
        </p>
      )}
    </section>
  );
}
