export type DocumentCategory = 'course' | 'exam' | 'review';

export interface SubjectOption {
  id: string;
  name: string;
  code: string;
  major_id: string | null;
}

export interface MajorOption {
  id: string;
  name: string;
  code: string;
}

export interface DocumentFolder {
  id: string;
  name: string;
  subject_id: string | null;
  major_id: string | null;
  major_name: string | null;
  semester: string;
  parent_folder_id: string | null;
  created_at: string;
}

export interface StudyDocument {
  id: string;
  subject_id: string | null;
  major_id: string | null;
  title: string;
  description: string;
  subject: string | null;
  category: DocumentCategory;
  file_path: string;
  file_type: string;
  file_size_bytes: number | null;
  file_size: number | null;
  is_published: boolean;
  folder_id: string | null;
  tags: string[];
  created_at: string;
  subject_name: string | null;
  major_name: string | null;
  folder_name: string | null;
}

export interface DocumentValues {
  title: string;
  description: string;
  majorId: string;
  subjectId: string;
  category: DocumentCategory;
  folderId: string;
  tags: string;
  isPublished: boolean;
}

export interface FolderValues {
  name: string;
  majorId: string;
  subjectId: string;
  semester: string;
  parentFolderId: string;
}
