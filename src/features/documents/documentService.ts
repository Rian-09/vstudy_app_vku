import { requireSupabase } from '../../lib/supabase/client';
import type {
  DocumentFolder,
  DocumentValues,
  FolderValues,
  MajorOption,
  StudyDocument,
  SubjectOption,
} from './types';

const DOCUMENT_COLUMNS =
  'id, subject_id, major_id, title, description, subject, category, file_path, file_type, file_size_bytes, file_size, is_published, folder_id, tags, created_at, subjects(name), majors(name), document_folders(name)';

export function isMajorSchemaMissing(error: unknown) {
  if (!error || typeof error !== 'object') return false;
  const { code, message } = error as { code?: unknown; message?: unknown };
  return (
    typeof code === 'string' &&
    typeof message === 'string' &&
    ['42P01', '42703', 'PGRST200', 'PGRST204'].includes(code) &&
    /major/i.test(message)
  );
}

export async function fetchDocuments(): Promise<StudyDocument[]> {
  const client = requireSupabase();
  const extended = await client
    .from('documents')
    .select(DOCUMENT_COLUMNS)
    .order('created_at', { ascending: false });
  if (!extended.error) {
    return (extended.data ?? []).map((row) => {
      const subjectJoin = Array.isArray(row.subjects)
        ? row.subjects[0]
        : row.subjects;
      const folderJoin = Array.isArray(row.document_folders)
        ? row.document_folders[0]
        : row.document_folders;
      const majorJoin = Array.isArray(row.majors) ? row.majors[0] : row.majors;
      return {
        ...row,
        subject_name: subjectJoin?.name ?? row.subject ?? null,
        major_name: majorJoin?.name ?? null,
        folder_name: folderJoin?.name ?? null,
      };
    }) as StudyDocument[];
  }
  if (!isMajorSchemaMissing(extended.error)) throw extended.error;

  const { data, error } = await client
    .from('documents')
    .select(
      'id, subject_id, title, description, subject, category, file_path, file_type, file_size_bytes, file_size, is_published, folder_id, tags, created_at, subjects(name), document_folders(name)',
    )
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map((row) => {
    const subjectJoin = Array.isArray(row.subjects)
      ? row.subjects[0]
      : row.subjects;
    const folderJoin = Array.isArray(row.document_folders)
      ? row.document_folders[0]
      : row.document_folders;
    return {
      ...row,
      major_id: null,
      subject_name: subjectJoin?.name ?? row.subject ?? null,
      major_name: null,
      folder_name: folderJoin?.name ?? null,
    };
  }) as StudyDocument[];
}

export async function fetchQuizDocuments(): Promise<StudyDocument[]> {
  const { data, error } = await requireSupabase()
    .from('documents')
    .select(
      'id, subject_id, title, description, subject, category, file_path, file_type, file_size_bytes, file_size, is_published, folder_id, tags, created_at, subjects(name), document_folders(name)',
    )
    .order('created_at', { ascending: false });
  if (error) throw error;

  return (data ?? []).map((row) => {
    const subjectJoin = Array.isArray(row.subjects)
      ? row.subjects[0]
      : row.subjects;
    const folderJoin = Array.isArray(row.document_folders)
      ? row.document_folders[0]
      : row.document_folders;
    return {
      ...row,
      major_id: null,
      major_name: null,
      subject_name: subjectJoin?.name ?? row.subject ?? null,
      folder_name: folderJoin?.name ?? null,
    };
  }) as StudyDocument[];
}

export async function fetchFolders(): Promise<DocumentFolder[]> {
  const client = requireSupabase();
  const extended = await client
    .from('document_folders')
    .select('id, name, subject_id, major_id, semester, parent_folder_id, created_at, majors(name)')
    .order('name');
  if (!extended.error) {
    return (extended.data ?? []).map((row) => {
      const major = Array.isArray(row.majors) ? row.majors[0] : row.majors;
      return { ...row, major_name: major?.name ?? null };
    }) as DocumentFolder[];
  }
  if (!isMajorSchemaMissing(extended.error)) throw extended.error;

  const { data, error } = await client
    .from('document_folders')
    .select('id, name, subject_id, semester, parent_folder_id, created_at')
    .order('name');
  if (error) throw error;
  return (data ?? []).map((row) => ({
    ...row,
    major_id: null,
    major_name: null,
  })) as DocumentFolder[];
}

export async function fetchSubjects(): Promise<SubjectOption[]> {
  const client = requireSupabase();
  const extended = await client
    .from('subjects')
    .select('id, name, code, major_id')
    .eq('is_active', true)
    .order('name');
  if (!extended.error) return (extended.data ?? []) as SubjectOption[];
  if (!isMajorSchemaMissing(extended.error)) throw extended.error;

  const { data, error } = await client
    .from('subjects')
    .select('id, name, code')
    .eq('is_active', true)
    .order('name');
  if (error) throw error;
  return (data ?? []).map((row) => ({ ...row, major_id: null })) as SubjectOption[];
}

export async function fetchMajorsForDocuments(): Promise<MajorOption[] | null> {
  const { data, error } = await requireSupabase()
    .from('majors')
    .select('id, name, code')
    .eq('is_active', true)
    .order('name');
  if (error && isMajorSchemaMissing(error)) return null;
  if (error) throw error;
  return (data ?? []) as MajorOption[];
}

function normalizeTags(rawTags: string) {
  return [...new Set(rawTags.split(',').map((tag) => tag.trim()).filter(Boolean))];
}

function getFileExtension(fileName: string) {
  return fileName.split('.').pop()?.toLowerCase() ?? '';
}

function getContentType(file: File) {
  if (file.type) return file.type;
  switch (getFileExtension(file.name)) {
    case 'pdf':
      return 'application/pdf';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'txt':
      return 'text/plain';
    default:
      return 'application/octet-stream';
  }
}

export async function uploadDocument(
  file: File,
  values: DocumentValues,
  title = values.title,
) {
  const client = requireSupabase();
  const {
    data: { user },
    error: userError,
  } = await client.auth.getUser();
  if (userError) throw userError;
  if (!user) throw new Error('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');

  const extension = getFileExtension(file.name);
  const filePath = `admin/${user.id}/${crypto.randomUUID()}.${extension}`;
  const storage = client.storage.from('documents');
  const { error: uploadError } = await storage.upload(filePath, file, {
    contentType: getContentType(file),
    upsert: false,
  });
  if (uploadError) throw uploadError;

  const subject = values.subjectId
    ? (await client
        .from('subjects')
        .select('name')
        .eq('id', values.subjectId)
        .single())
    : null;
  if (subject?.error) {
    const { error: cleanupError } = await storage.remove([filePath]);
    if (cleanupError) {
      throw new Error(
        `Không đọc được môn học; tệp ${filePath} cũng không thể dọn khỏi Storage: ${cleanupError.message}`,
      );
    }
    throw subject.error;
  }

  const documentValues = {
    subject_id: values.subjectId || null,
    ...(values.majorId ? { major_id: values.majorId } : {}),
    subject: subject?.data?.name ?? null,
    title: title.trim(),
    description: values.description.trim(),
    category: values.category,
    file_path: filePath,
    file_type: extension,
    file_size_bytes: file.size,
    file_size: file.size,
    is_published: values.isPublished,
    created_by: user.id,
    folder_id: values.folderId || null,
    tags: normalizeTags(values.tags),
  };
  const { data, error } = await client
    .from('documents')
    .insert(documentValues)
    .select('id')
    .single();

  if (error) {
    const { error: cleanupError } = await storage.remove([filePath]);
    if (cleanupError) {
      throw new Error(
        `Không lưu được metadata (${error.message}); tệp ${filePath} cũng không thể dọn khỏi Storage: ${cleanupError.message}`,
      );
    }
    throw error;
  }
  return data;
}

export async function updateDocument(
  documentId: string,
  values: DocumentValues,
  subjectName: string | null,
) {
  const client = requireSupabase();
  const payload = {
    title: values.title.trim(),
    description: values.description.trim(),
    major_id: values.majorId || null,
    subject_id: values.subjectId || null,
    subject: subjectName,
    category: values.category,
    folder_id: values.folderId || null,
    tags: normalizeTags(values.tags),
    is_published: values.isPublished,
  };
  const { error } = await client
    .from('documents')
    .update(payload)
    .eq('id', documentId);
  if (!error) return;
  if (!isMajorSchemaMissing(error) || values.majorId) throw error;
  const { major_id: _majorId, ...legacyPayload } = payload;
  const retry = await client
    .from('documents')
    .update(legacyPayload)
    .eq('id', documentId);
  if (retry.error) throw retry.error;
}

export async function moveDocument(documentId: string, folderId: string) {
  const { error } = await requireSupabase()
    .from('documents')
    .update({ folder_id: folderId || null })
    .eq('id', documentId);
  if (error) throw error;
}

export async function deleteDocument(document: StudyDocument) {
  const client = requireSupabase();
  const { error: storageError } = await client.storage
    .from('documents')
    .remove([document.file_path]);
  if (storageError) throw storageError;

  const { error: rowError } = await client
    .from('documents')
    .delete()
    .eq('id', document.id);
  if (rowError) {
    throw new Error(
      `Đã xóa tệp khỏi Storage nhưng không xóa được metadata tài liệu: ${rowError.message}`,
    );
  }
}

export async function createFolder(values: FolderValues) {
  const client = requireSupabase();
  const payload = {
    name: values.name.trim(),
    major_id: values.majorId || null,
    subject_id: values.subjectId || null,
    semester: values.semester.trim(),
    parent_folder_id: values.parentFolderId || null,
  };
  const { error } = await client
    .from('document_folders')
    .insert(payload);
  if (!error) return;
  if (!isMajorSchemaMissing(error) || values.majorId) throw error;
  const { major_id: _majorId, ...legacyPayload } = payload;
  const retry = await client
    .from('document_folders')
    .insert(legacyPayload);
  if (retry.error) throw retry.error;
}

export async function updateFolder(folderId: string, values: FolderValues) {
  const client = requireSupabase();
  const payload = {
    name: values.name.trim(),
    major_id: values.majorId || null,
    subject_id: values.subjectId || null,
    semester: values.semester.trim(),
    parent_folder_id: values.parentFolderId || null,
  };
  const { error } = await client
    .from('document_folders')
    .update(payload)
    .eq('id', folderId);
  if (!error) return;
  if (!isMajorSchemaMissing(error) || values.majorId) throw error;
  const { major_id: _majorId, ...legacyPayload } = payload;
  const retry = await client
    .from('document_folders')
    .update(legacyPayload)
    .eq('id', folderId);
  if (retry.error) throw retry.error;
}

export async function deleteEmptyFolder(folder: DocumentFolder) {
  const client = requireSupabase();
  const [children, documents] = await Promise.all([
    client
      .from('document_folders')
      .select('id', { count: 'exact', head: true })
      .eq('parent_folder_id', folder.id),
    client
      .from('documents')
      .select('id', { count: 'exact', head: true })
      .eq('folder_id', folder.id),
  ]);
  if (children.error) throw children.error;
  if (documents.error) throw documents.error;
  if ((children.count ?? 0) > 0 || (documents.count ?? 0) > 0) {
    throw new Error(
      'Thư mục còn thư mục con hoặc tài liệu. Hãy di chuyển/xóa các mục bên trong trước.',
    );
  }

  const { error } = await client
    .from('document_folders')
    .delete()
    .eq('id', folder.id);
  if (error) throw error;
}

export async function createSignedDocumentUrl(
  filePath: string,
  download = false,
) {
  const { data, error } = await requireSupabase()
    .storage.from('documents')
    .createSignedUrl(filePath, 300, download ? { download: true } : undefined);
  if (error) throw error;
  return data.signedUrl;
}

export function getDocumentSize(document: StudyDocument) {
  const size = document.file_size ?? document.file_size_bytes;
  if (size == null || size < 0) return '—';
  if (size >= 1024 * 1024) return `${(size / 1024 / 1024).toFixed(1)} MB`;
  if (size >= 1024) return `${(size / 1024).toFixed(0)} KB`;
  return `${size} B`;
}

export function getDocumentFileName(document: StudyDocument) {
  return document.file_path.split('/').pop() ?? document.title;
}

export function getDocumentExtension(document: StudyDocument) {
  const fileType = document.file_type.toLowerCase();
  if (fileType.includes('pdf')) return 'pdf';
  if (fileType.includes('wordprocessingml')) return 'docx';
  if (fileType.includes('presentationml')) return 'pptx';
  if (fileType.includes('text/plain')) return 'txt';
  if (['pdf', 'docx', 'pptx', 'txt'].includes(fileType)) return fileType;
  return getDocumentFileName(document).split('.').pop()?.toLowerCase() ?? '';
}

export function isSupportedDocument(file: File) {
  return ['pdf', 'docx', 'pptx', 'txt'].includes(getFileExtension(file.name));
}

