import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  ArrowDownToLine,
  Eye,
  FilePlus2,
  FileText,
  FolderInput,
  Pencil,
  Search,
  Trash2,
} from 'lucide-react';
import { useMemo, useState } from 'react';
import { toast } from 'sonner';
import { Button } from '../../components/ui/button';
import { ConfirmDialog } from '../../components/ui/confirm-dialog';
import { Input } from '../../components/ui/input';
import {
  createFolder,
  createSignedDocumentUrl,
  deleteDocument,
  deleteEmptyFolder,
  fetchDocuments,
  fetchFolders,
  fetchMajorsForDocuments,
  fetchSubjects,
  getDocumentExtension,
  getDocumentFileName,
  getDocumentSize,
  moveDocument,
  updateDocument,
  updateFolder,
  uploadDocument,
} from './documentService';
import { DocumentEditorDialog } from './DocumentEditorDialog';
import { DocumentPreviewDialog } from './DocumentPreviewDialog';
import { FolderEditorDialog, type FolderEditorMode } from './FolderEditorDialog';
import { FolderTree } from './FolderTree';
import { MoveDocumentDialog } from './MoveDocumentDialog';
import type {
  DocumentFolder,
  DocumentValues,
  FolderValues,
  StudyDocument,
} from './types';

type FolderEditorState = {
  mode: FolderEditorMode;
  folder: DocumentFolder | null;
  parentFolderId: string | null;
};

type PendingDelete =
  | { kind: 'document'; document: StudyDocument }
  | { kind: 'folder'; folder: DocumentFolder };

function formatDate(value: string) {
  return new Intl.DateTimeFormat('vi-VN', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

function errorText(error: unknown) {
  return error instanceof Error ? error.message : 'Vui lòng thử lại.';
}

export function DocumentManagementPage() {
  const queryClient = useQueryClient();
  const documentsQuery = useQuery({
    queryKey: ['admin-documents'],
    queryFn: fetchDocuments,
  });
  const foldersQuery = useQuery({
    queryKey: ['admin-document-folders'],
    queryFn: fetchFolders,
  });
  const subjectsQuery = useQuery({
    queryKey: ['admin-subjects'],
    queryFn: fetchSubjects,
  });
  const majorsQuery = useQuery({
    queryKey: ['admin-document-majors'],
    queryFn: fetchMajorsForDocuments,
  });

  const [selectedFolderId, setSelectedFolderId] = useState<string | null>(null);
  const [selectedMajorId, setSelectedMajorId] = useState('');
  const [search, setSearch] = useState('');
  const [fileType, setFileType] = useState('all');
  const [isEditorOpen, setIsEditorOpen] = useState(false);
  const [editingDocument, setEditingDocument] = useState<StudyDocument | null>(
    null,
  );
  const [folderEditor, setFolderEditor] = useState<FolderEditorState | null>(
    null,
  );
  const [movingDocument, setMovingDocument] = useState<StudyDocument | null>(
    null,
  );
  const [previewDocument, setPreviewDocument] = useState<StudyDocument | null>(
    null,
  );
  const [pendingDelete, setPendingDelete] = useState<PendingDelete | null>(null);
  const [isSavingDocument, setIsSavingDocument] = useState(false);

  const documents = documentsQuery.data ?? [];
  const folders = foldersQuery.data ?? [];
  const subjects = subjectsQuery.data ?? [];
  const majors = majorsQuery.data ?? [];
  const filteredDocuments = useMemo(() => {
    const searchTerm = search.trim().toLocaleLowerCase('vi');
    return documents.filter((document) => {
      if (selectedFolderId && document.folder_id !== selectedFolderId) {
        return false;
      }
      if (selectedMajorId && document.major_id !== selectedMajorId) {
        return false;
      }
      if (
        fileType !== 'all' &&
        getDocumentExtension(document) !== fileType
      ) {
        return false;
      }
      if (!searchTerm) return true;
      const searchableText = [
        document.title,
        document.description,
        document.major_name ?? '',
        document.subject_name ?? '',
        document.folder_name ?? '',
        getDocumentFileName(document),
        ...document.tags,
      ]
        .join(' ')
        .toLocaleLowerCase('vi');
      return searchableText.includes(searchTerm);
    });
  }, [documents, fileType, search, selectedFolderId, selectedMajorId]);

  const refreshDocumentData = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ['admin-documents'] }),
      queryClient.invalidateQueries({ queryKey: ['admin-document-folders'] }),
      queryClient.invalidateQueries({ queryKey: ['admin-document-majors'] }),
    ]);
  };

  const folderMutation = useMutation({
    mutationFn: ({
      editor,
      values,
    }: {
      editor: FolderEditorState;
      values: FolderValues;
    }) => {
      if (editor.mode === 'create') return createFolder(values);
      if (!editor.folder) throw new Error('Không tìm thấy thư mục cần cập nhật.');
      return updateFolder(editor.folder.id, values);
    },
    onSuccess: async (_data, variables) => {
      toast.success(
        variables.editor.mode === 'create'
          ? 'Đã tạo thư mục.'
          : variables.editor.mode === 'move'
            ? 'Đã di chuyển thư mục.'
            : 'Đã cập nhật thư mục.',
      );
      setFolderEditor(null);
      await refreshDocumentData();
    },
    onError: (error) => toast.error(errorText(error)),
  });

  const deleteMutation = useMutation({
    mutationFn: (item: PendingDelete) =>
      item.kind === 'document'
        ? deleteDocument(item.document)
        : deleteEmptyFolder(item.folder),
    onSuccess: async (_data, item) => {
      toast.success(
        item.kind === 'document' ? 'Đã xóa tài liệu.' : 'Đã xóa thư mục.',
      );
      if (item.kind === 'folder' && selectedFolderId === item.folder.id) {
        setSelectedFolderId(null);
      }
      setPendingDelete(null);
      await refreshDocumentData();
    },
    onError: (error) => {
      setPendingDelete(null);
      toast.error(errorText(error));
    },
  });

  const moveDocumentMutation = useMutation({
    mutationFn: ({
      documentId,
      folderId,
    }: {
      documentId: string;
      folderId: string;
    }) => moveDocument(documentId, folderId),
    onSuccess: async () => {
      toast.success('Đã di chuyển tài liệu.');
      setMovingDocument(null);
      await refreshDocumentData();
    },
    onError: (error) => toast.error(errorText(error)),
  });

  const saveFolder = (values: FolderValues) => {
    if (!folderEditor) return;
    folderMutation.mutate({ editor: folderEditor, values });
  };

  const saveDocument = async (values: DocumentValues, files: File[]) => {
    setIsSavingDocument(true);
    try {
      if (editingDocument) {
        const subjectName =
          subjects.find((subject) => subject.id === values.subjectId)?.name ??
          null;
        await updateDocument(editingDocument.id, values, subjectName);
        toast.success('Đã lưu thông tin tài liệu.');
      } else {
        const results = await Promise.allSettled(
          files.map((file) => {
            const title =
              files.length > 1
                ? file.name.replace(/\.[^.]+$/, '')
                : values.title;
            return uploadDocument(file, values, title);
          }),
        );
        const succeeded = results.filter(
          (result) => result.status === 'fulfilled',
        ).length;
        const failures = results.flatMap((result, index) =>
          result.status === 'rejected'
            ? [
                `${files[index].name}: ${
                  result.reason instanceof Error
                    ? result.reason.message
                    : 'Lỗi không xác định'
                }`,
              ]
            : [],
        );

        if (succeeded === 0) {
          throw new Error(failures.join('\n') || 'Không thể tải tệp lên.');
        }
        toast.success(`Đã tải lên ${succeeded} tài liệu.`);
        if (failures.length) {
          toast.error(`Một số tệp chưa tải lên được: ${failures.join(' · ')}`);
        }
      }
      setIsEditorOpen(false);
      setEditingDocument(null);
      await refreshDocumentData();
    } catch (error) {
      toast.error(errorText(error));
    } finally {
      setIsSavingDocument(false);
    }
  };

  const handleDownload = async (document: StudyDocument) => {
    try {
      const url = await createSignedDocumentUrl(document.file_path, true);
      const link = window.document.createElement('a');
      link.href = url;
      link.download = getDocumentFileName(document);
      link.rel = 'noreferrer';
      link.click();
    } catch (error) {
      toast.error(`Không thể tải tài liệu: ${errorText(error)}`);
    }
  };

  const isLoading =
    documentsQuery.isPending ||
    foldersQuery.isPending ||
    subjectsQuery.isPending ||
    majorsQuery.isPending;
  const loadError =
    documentsQuery.error ??
    foldersQuery.error ??
    subjectsQuery.error ??
    majorsQuery.error;

  return (
    <div className="space-y-6">
      <header className="flex flex-col justify-between gap-4 sm:flex-row sm:items-end">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
            Kho học liệu
          </p>
          <h1 className="mt-2 text-2xl font-bold text-brand-ink">
            Quản lý tài liệu
          </h1>
          <p className="mt-1 text-sm text-brand-muted">
            Tổ chức tài liệu theo môn học/học kỳ và lưu file trong Supabase
            Storage.
          </p>
        </div>
        <Button
          variant="yellow"
          onClick={() => {
            setEditingDocument(null);
            setIsEditorOpen(true);
          }}
        >
          <FilePlus2 size={17} />
          Tải tài liệu lên
        </Button>
      </header>

      {majorsQuery.data === null && (
        <p className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-950">
          Quản lý ngành cần migration{' '}
          <code>202611230004_major_catalog_and_document_scope.sql</code>. Các
          chức năng tài liệu hiện tại vẫn dùng được; trường ngành sẽ xuất hiện
          sau khi migration được duyệt và áp dụng.
        </p>
      )}

      {isLoading ? (
        <div className="grid min-w-0 gap-4 lg:grid-cols-[220px_minmax(0,1fr)] xl:grid-cols-[240px_minmax(0,1fr)]">
          <div className="h-72 animate-pulse rounded-2xl bg-slate-200" />
          <div className="h-72 animate-pulse rounded-2xl bg-slate-200" />
        </div>
      ) : loadError ? (
        <section
          role="alert"
          className="rounded-2xl border border-red-200 bg-red-50 p-5 text-sm text-red-800"
        >
          <p className="font-semibold">Không tải được dữ liệu tài liệu.</p>
          <p className="mt-1 break-words">{errorText(loadError)}</p>
          <Button
            variant="outline"
            size="sm"
            className="mt-3"
            onClick={() => {
              void documentsQuery.refetch();
              void foldersQuery.refetch();
              void subjectsQuery.refetch();
              void majorsQuery.refetch();
            }}
          >
            Thử tải lại
          </Button>
        </section>
      ) : (
        <div className="grid min-w-0 items-start gap-4 lg:grid-cols-[220px_minmax(0,1fr)] xl:grid-cols-[240px_minmax(0,1fr)]">
          <FolderTree
            folders={folders}
            selectedFolderId={selectedFolderId}
            onSelect={setSelectedFolderId}
            onCreate={(parentFolderId) =>
              setFolderEditor({
                mode: 'create',
                folder: null,
                parentFolderId,
              })
            }
            onRename={(folder) =>
              setFolderEditor({
                mode: 'rename',
                folder,
                parentFolderId: folder.parent_folder_id,
              })
            }
            onMove={(folder) =>
              setFolderEditor({
                mode: 'move',
                folder,
                parentFolderId: folder.parent_folder_id,
              })
            }
            onDelete={(folder) => setPendingDelete({ kind: 'folder', folder })}
          />

          <section className="min-w-0 rounded-2xl border border-brand-purple/10 bg-white p-4 shadow-sm sm:p-5">
            <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-[minmax(170px,1fr)_140px_180px]">
              <label className="relative block">
                <Search
                  size={17}
                  className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400"
                />
                <Input
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder="Tìm tên, tag hoặc môn học..."
                  aria-label="Tìm tài liệu"
                  className="pl-10"
                />
              </label>
              <select
                value={fileType}
                onChange={(event) => setFileType(event.target.value)}
                className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
                aria-label="Lọc loại file"
              >
                <option value="all">Mọi loại file</option>
                <option value="pdf">PDF</option>
                <option value="docx">DOCX</option>
                <option value="pptx">PPTX</option>
                <option value="txt">TXT</option>
              </select>
              <select
                value={selectedMajorId}
                onChange={(event) => setSelectedMajorId(event.target.value)}
                className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink outline-none focus:border-brand-blue"
                aria-label="Lọc theo ngành học"
              >
                <option value="">Tất cả ngành học</option>
                {majors.map((major) => (
                  <option key={major.id} value={major.id}>
                    {major.code} · {major.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="mt-4 flex items-center justify-between border-b border-slate-100 pb-3">
              <h2 className="text-sm font-bold text-brand-ink">
                {selectedFolderId
                  ? folders.find((folder) => folder.id === selectedFolderId)
                      ?.name ?? 'Tài liệu'
                  : 'Tất cả tài liệu'}
              </h2>
              <span className="text-xs text-brand-muted">
                {filteredDocuments.length.toLocaleString('vi-VN')} tài liệu
              </span>
            </div>

            <div className="mt-2 divide-y divide-brand-purple/10">
              {filteredDocuments.map((document) => (
                <article
                  key={document.id}
                  className="grid min-w-0 gap-3 px-1 py-4 transition hover:bg-brand-lavender/30 sm:px-2 lg:grid-cols-[minmax(0,1fr)_minmax(150px,0.9fr)_168px] lg:items-center"
                >
                  <div className="flex min-w-0 items-start gap-2.5">
                    <span className="mt-0.5 grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-brand-lavender text-brand-purple">
                      <FileText size={17} />
                    </span>
                    <span className="min-w-0">
                      <span className="block break-words text-sm font-semibold leading-5 text-brand-ink">
                        {document.title}
                      </span>
                      <span className="mt-1 flex flex-wrap gap-1">
                        {document.tags.slice(0, 3).map((tag) => (
                          <span
                            key={tag}
                            className="rounded bg-brand-lavender px-1.5 py-0.5 text-[10px] text-brand-purple"
                          >
                            {tag}
                          </span>
                        ))}
                      </span>
                    </span>
                  </div>

                  <div className="grid min-w-0 grid-cols-2 gap-x-3 gap-y-1 text-[11px] leading-4 text-brand-muted lg:grid-cols-1">
                    <span className="truncate" title={document.major_name ?? ''}>
                      {document.major_name || 'Chưa phân loại ngành'}
                    </span>
                    <span className="truncate" title={document.subject_name ?? ''}>
                      {document.subject_name || 'Chưa phân loại môn'}
                    </span>
                    <span className="truncate" title={document.folder_name ?? ''}>
                      {document.folder_name || 'Không thuộc thư mục'}
                    </span>
                    <span className="truncate">
                      <strong className="uppercase text-brand-ink">{document.file_type}</strong>
                      {' · '}
                      {getDocumentSize(document)}
                    </span>
                    <span className="truncate">{formatDate(document.created_at)}</span>
                    <span
                      className={`w-fit rounded-full px-2 py-0.5 text-[10px] font-semibold ${
                        document.is_published
                          ? 'bg-brand-lime/30 text-brand-purple'
                          : 'bg-slate-100 text-slate-600'
                      }`}
                    >
                      {document.is_published ? 'Đã publish' : 'Bản nháp'}
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center justify-start gap-0.5 lg:justify-end">
                    {['pdf', 'docx', 'pptx', 'txt'].includes(
                      getDocumentExtension(document),
                    ) && (
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-8 w-8"
                        title="Xem trước"
                        aria-label={`Xem ${document.title}`}
                        onClick={() => setPreviewDocument(document)}
                      >
                        <Eye size={16} />
                      </Button>
                    )}
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      title="Tải xuống"
                      aria-label={`Tải ${document.title}`}
                      onClick={() => void handleDownload(document)}
                    >
                      <ArrowDownToLine size={16} />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      title="Di chuyển"
                      aria-label={`Di chuyển ${document.title}`}
                      onClick={() => setMovingDocument(document)}
                    >
                      <FolderInput size={16} />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      title="Sửa metadata"
                      aria-label={`Sửa ${document.title}`}
                      onClick={() => {
                        setEditingDocument(document);
                        setIsEditorOpen(true);
                      }}
                    >
                      <Pencil size={16} />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 text-brand-red hover:bg-red-50 hover:text-brand-red"
                      title="Xóa"
                      aria-label={`Xóa ${document.title}`}
                      onClick={() =>
                        setPendingDelete({ kind: 'document', document })
                      }
                    >
                      <Trash2 size={16} />
                    </Button>
                  </div>
                </article>
              ))}
              {filteredDocuments.length === 0 && (
                <p className="px-3 py-12 text-center text-sm text-brand-muted">
                  Không tìm thấy tài liệu phù hợp.
                </p>
              )}
            </div>
          </section>
        </div>
      )}

      {isEditorOpen && (
        <DocumentEditorDialog
          document={editingDocument}
          initialFolderId={selectedFolderId}
          folders={folders}
          majors={majors}
          subjects={subjects}
          isSaving={isSavingDocument}
          onClose={() => {
            if (!isSavingDocument) {
              setIsEditorOpen(false);
              setEditingDocument(null);
            }
          }}
          onSave={saveDocument}
        />
      )}

      {folderEditor && (
        <FolderEditorDialog
          mode={folderEditor.mode}
          folder={folderEditor.folder}
          initialParentId={folderEditor.parentFolderId}
          folders={folders}
          majors={majors}
          subjects={subjects}
          isSaving={folderMutation.isPending}
          onClose={() => setFolderEditor(null)}
          onSave={saveFolder}
        />
      )}

      {movingDocument && (
        <MoveDocumentDialog
          document={movingDocument}
          folders={folders}
          isSaving={moveDocumentMutation.isPending}
          onClose={() => setMovingDocument(null)}
          onMove={(folderId) =>
            moveDocumentMutation.mutate({
              documentId: movingDocument.id,
              folderId,
            })
          }
        />
      )}

      {previewDocument && (
        <DocumentPreviewDialog
          document={previewDocument}
          onClose={() => setPreviewDocument(null)}
          onDownload={(document) => void handleDownload(document)}
        />
      )}

      {pendingDelete && (
        <ConfirmDialog
          title={
            pendingDelete.kind === 'document'
              ? 'Xóa tài liệu này?'
              : 'Xóa thư mục rỗng?'
          }
          description={
            pendingDelete.kind === 'document'
              ? `Tệp "${pendingDelete.document.title}" và metadata sẽ bị xóa khỏi kho tài liệu.`
              : `Chỉ xóa được thư mục "${pendingDelete.folder.name}" khi thư mục không còn tài liệu hoặc thư mục con.`
          }
          confirmLabel="Xóa"
          isDestructive
          isPending={deleteMutation.isPending}
          onCancel={() => setPendingDelete(null)}
          onConfirm={() => deleteMutation.mutate(pendingDelete)}
        />
      )}
    </div>
  );
}
