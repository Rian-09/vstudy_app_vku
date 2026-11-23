import { requireSupabase } from '../../lib/supabase/client';

export interface Major {
  id: string;
  code: string;
  name: string;
  description: string;
  is_active: boolean;
}

export interface CatalogSubject {
  id: string;
  code: string;
  name: string;
  description: string;
  credits: number;
  is_active: boolean;
  major_id: string | null;
  major_name: string | null;
}

export interface MajorValues {
  code: string;
  name: string;
  description: string;
}

export interface SubjectValues {
  code: string;
  name: string;
  description: string;
  credits: number;
  majorId: string;
}

export async function fetchMajors(): Promise<Major[]> {
  const { data, error } = await requireSupabase()
    .from('majors')
    .select('id, code, name, description, is_active')
    .order('name');
  if (error) throw error;
  return data ?? [];
}

export async function fetchCatalogSubjects(): Promise<CatalogSubject[]> {
  const { data, error } = await requireSupabase()
    .from('subjects')
    .select('id, code, name, description, credits, is_active, major_id, majors(name)')
    .order('name');
  if (error) throw error;

  return (data ?? []).map((row) => {
    const major = Array.isArray(row.majors) ? row.majors[0] : row.majors;
    return { ...row, major_name: major?.name ?? null };
  }) as CatalogSubject[];
}

export async function saveMajor(id: string | null, values: MajorValues) {
  const client = requireSupabase();
  const query = id
    ? client.from('majors').update(values).eq('id', id)
    : client.from('majors').insert(values);
  const { error } = await query;
  if (error) throw error;
}

export async function saveSubject(
  id: string | null,
  values: SubjectValues,
) {
  const client = requireSupabase();
  const payload = {
    code: values.code,
    name: values.name,
    description: values.description,
    credits: values.credits,
    major_id: values.majorId || null,
  };
  const query = id
    ? client.from('subjects').update(payload).eq('id', id)
    : client.from('subjects').insert(payload);
  const { error } = await query;
  if (error) throw error;
}

export async function setCatalogItemActive(
  kind: 'major' | 'subject',
  id: string,
  isActive: boolean,
) {
  const table = kind === 'major' ? 'majors' : 'subjects';
  const { error } = await requireSupabase()
    .from(table)
    .update({ is_active: isActive })
    .eq('id', id);
  if (error) throw error;
}
