import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { toast } from 'sonner';
import { Button } from '../../components/ui/button';
import { Input } from '../../components/ui/input';
import { isMajorSchemaMissing } from '../documents/documentService';
import {
  fetchCatalogSubjects,
  fetchMajors,
  saveMajor,
  saveSubject,
  setCatalogItemActive,
  type CatalogSubject,
  type Major,
  type MajorValues,
  type SubjectValues,
} from './catalogService';

const emptyMajor: MajorValues = { code: '', name: '', description: '' };
const emptySubject: SubjectValues = {
  code: '',
  name: '',
  description: '',
  credits: 0,
  majorId: '',
};

function message(error: unknown) {
  return error instanceof Error ? error.message : 'Vui lòng thử lại.';
}

export function CatalogManagementPage() {
  const queryClient = useQueryClient();
  const majorsQuery = useQuery({
    queryKey: ['admin-majors'],
    queryFn: fetchMajors,
  });
  const subjectsQuery = useQuery({
    queryKey: ['admin-catalog-subjects'],
    queryFn: fetchCatalogSubjects,
  });
  const [majorId, setMajorId] = useState<string | null>(null);
  const [majorValues, setMajorValues] = useState<MajorValues>(emptyMajor);
  const [subjectId, setSubjectId] = useState<string | null>(null);
  const [subjectValues, setSubjectValues] =
    useState<SubjectValues>(emptySubject);

  const refresh = async () => {
    await Promise.all([
      queryClient.invalidateQueries({ queryKey: ['admin-majors'] }),
      queryClient.invalidateQueries({ queryKey: ['admin-catalog-subjects'] }),
      queryClient.invalidateQueries({ queryKey: ['admin-subjects'] }),
      queryClient.invalidateQueries({ queryKey: ['admin-document-majors'] }),
      queryClient.invalidateQueries({ queryKey: ['quiz-subjects'] }),
    ]);
  };
  const saveMajorMutation = useMutation({
    mutationFn: () => saveMajor(majorId, {
      code: majorValues.code.trim(),
      name: majorValues.name.trim(),
      description: majorValues.description.trim(),
    }),
    onSuccess: async () => {
      toast.success(majorId ? 'Đã cập nhật ngành.' : 'Đã tạo ngành.');
      setMajorId(null);
      setMajorValues(emptyMajor);
      await refresh();
    },
    onError: (error) => toast.error(message(error)),
  });
  const saveSubjectMutation = useMutation({
    mutationFn: () => saveSubject(subjectId, {
      ...subjectValues,
      code: subjectValues.code.trim(),
      name: subjectValues.name.trim(),
      description: subjectValues.description.trim(),
    }),
    onSuccess: async () => {
      toast.success(subjectId ? 'Đã cập nhật môn học.' : 'Đã tạo môn học.');
      setSubjectId(null);
      setSubjectValues(emptySubject);
      await refresh();
    },
    onError: (error) => toast.error(message(error)),
  });
  const activeMutation = useMutation({
    mutationFn: ({
      kind,
      id,
      isActive,
    }: {
      kind: 'major' | 'subject';
      id: string;
      isActive: boolean;
    }) => setCatalogItemActive(kind, id, isActive),
    onSuccess: refresh,
    onError: (error) => toast.error(message(error)),
  });

  const majors = majorsQuery.data ?? [];
  const subjects = subjectsQuery.data ?? [];
  const loadError = majorsQuery.error ?? subjectsQuery.error;
  const isLoading = majorsQuery.isPending || subjectsQuery.isPending;

  const editMajor = (major: Major) => {
    setMajorId(major.id);
    setMajorValues({
      code: major.code,
      name: major.name,
      description: major.description,
    });
  };
  const editSubject = (subject: CatalogSubject) => {
    setSubjectId(subject.id);
    setSubjectValues({
      code: subject.code,
      name: subject.name,
      description: subject.description,
      credits: subject.credits,
      majorId: subject.major_id ?? '',
    });
  };

  return (
    <div className="space-y-6">
      <header>
        <p className="text-xs font-bold uppercase tracking-[0.16em] text-brand-blue">
          Danh mục đào tạo
        </p>
        <h1 className="mt-2 text-2xl font-bold text-brand-ink">
          Quản lý ngành và môn học
        </h1>
        <p className="mt-1 text-sm text-brand-muted">
          Tạo danh mục ngành, gắn môn học vào ngành và dùng chúng để phân loại
          tài liệu.
        </p>
      </header>

      {loadError && (
        <section role="alert" className="rounded-xl bg-red-50 p-4 text-sm text-red-800">
          <p className="font-semibold">
            {isMajorSchemaMissing(loadError)
              ? 'Danh mục ngành chưa có trong cơ sở dữ liệu.'
              : 'Không tải được danh mục.'}
          </p>
          {isMajorSchemaMissing(loadError) && (
            <p className="mt-1">
              Cần duyệt và áp dụng migration{' '}
              <code>202611230004_major_catalog_and_document_scope.sql</code>.
            </p>
          )}
          <p className="mt-1">{message(loadError)}</p>
          <Button
            variant="outline"
            size="sm"
            className="mt-3"
            onClick={() => {
              void majorsQuery.refetch();
              void subjectsQuery.refetch();
            }}
          >
            Thử tải lại
          </Button>
        </section>
      )}

      {isLoading ? (
        <div className="grid gap-5 xl:grid-cols-2">
          <div className="h-80 animate-pulse rounded-2xl bg-slate-200" />
          <div className="h-80 animate-pulse rounded-2xl bg-slate-200" />
        </div>
      ) : (
        <div className="grid items-start gap-5 xl:grid-cols-2">
          <section className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm">
            <h2 className="text-lg font-bold text-brand-ink">Ngành học</h2>
            <form
              className="mt-4 grid gap-3"
              onSubmit={(event) => {
                event.preventDefault();
                if (majorValues.code.trim() && majorValues.name.trim()) {
                  saveMajorMutation.mutate();
                }
              }}
            >
              <div className="grid gap-3 sm:grid-cols-2">
                <Input
                  required
                  aria-label="Mã ngành"
                  placeholder="Mã ngành"
                  value={majorValues.code}
                  onChange={(event) =>
                    setMajorValues({ ...majorValues, code: event.target.value })
                  }
                />
                <Input
                  required
                  aria-label="Tên ngành"
                  placeholder="Tên ngành"
                  value={majorValues.name}
                  onChange={(event) =>
                    setMajorValues({ ...majorValues, name: event.target.value })
                  }
                />
              </div>
              <Input
                aria-label="Mô tả ngành"
                placeholder="Mô tả (không bắt buộc)"
                value={majorValues.description}
                onChange={(event) =>
                  setMajorValues({ ...majorValues, description: event.target.value })
                }
              />
              <div className="flex gap-2">
                <Button
                  type="submit"
                  variant="yellow"
                  disabled={saveMajorMutation.isPending}
                >
                  {majorId ? 'Lưu ngành' : 'Thêm ngành'}
                </Button>
                {majorId && (
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => {
                      setMajorId(null);
                      setMajorValues(emptyMajor);
                    }}
                  >
                    Hủy sửa
                  </Button>
                )}
              </div>
            </form>

            <div className="mt-5 divide-y divide-slate-100">
              {majors.map((major) => (
                <div key={major.id} className="flex items-center gap-3 py-3">
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-semibold text-brand-ink">
                      {major.name}
                    </p>
                    <p className="text-xs text-brand-muted">
                      {major.code} · {major.is_active ? 'Đang dùng' : 'Đã ẩn'}
                    </p>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => editMajor(major)}
                  >
                    Sửa
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={activeMutation.isPending}
                    onClick={() =>
                      activeMutation.mutate({
                        kind: 'major',
                        id: major.id,
                        isActive: !major.is_active,
                      })
                    }
                  >
                    {major.is_active ? 'Ẩn' : 'Hiện'}
                  </Button>
                </div>
              ))}
              {majors.length === 0 && (
                <p className="py-6 text-center text-sm text-brand-muted">
                  Chưa có ngành học.
                </p>
              )}
            </div>
          </section>

          <section className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm">
            <h2 className="text-lg font-bold text-brand-ink">Môn học</h2>
            <form
              className="mt-4 grid gap-3"
              onSubmit={(event) => {
                event.preventDefault();
                if (subjectValues.code.trim() && subjectValues.name.trim()) {
                  saveSubjectMutation.mutate();
                }
              }}
            >
              <div className="grid gap-3 sm:grid-cols-2">
                <Input
                  required
                  aria-label="Mã môn học"
                  placeholder="Mã môn học"
                  value={subjectValues.code}
                  onChange={(event) =>
                    setSubjectValues({ ...subjectValues, code: event.target.value })
                  }
                />
                <Input
                  required
                  aria-label="Tên môn học"
                  placeholder="Tên môn học"
                  value={subjectValues.name}
                  onChange={(event) =>
                    setSubjectValues({ ...subjectValues, name: event.target.value })
                  }
                />
              </div>
              <div className="grid gap-3 sm:grid-cols-[minmax(0,1fr)_120px]">
                <select
                  value={subjectValues.majorId}
                  onChange={(event) =>
                    setSubjectValues({ ...subjectValues, majorId: event.target.value })
                  }
                  className="h-11 rounded-xl border border-slate-200 bg-white px-3 text-sm text-brand-ink"
                  aria-label="Ngành của môn học"
                >
                  <option value="">Chưa gắn ngành</option>
                  {majors.filter((major) => major.is_active).map((major) => (
                    <option key={major.id} value={major.id}>
                      {major.code} · {major.name}
                    </option>
                  ))}
                </select>
                <Input
                  type="number"
                  min={0}
                  aria-label="Số tín chỉ"
                  placeholder="Tín chỉ"
                  value={subjectValues.credits}
                  onChange={(event) =>
                    setSubjectValues({
                      ...subjectValues,
                      credits: Math.max(0, Number(event.target.value)),
                    })
                  }
                />
              </div>
              <Input
                aria-label="Mô tả môn học"
                placeholder="Mô tả (không bắt buộc)"
                value={subjectValues.description}
                onChange={(event) =>
                  setSubjectValues({ ...subjectValues, description: event.target.value })
                }
              />
              <div className="flex gap-2">
                <Button
                  type="submit"
                  variant="yellow"
                  disabled={saveSubjectMutation.isPending}
                >
                  {subjectId ? 'Lưu môn học' : 'Thêm môn học'}
                </Button>
                {subjectId && (
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => {
                      setSubjectId(null);
                      setSubjectValues(emptySubject);
                    }}
                  >
                    Hủy sửa
                  </Button>
                )}
              </div>
            </form>

            <div className="mt-5 divide-y divide-slate-100">
              {subjects.map((subject) => (
                <div key={subject.id} className="flex items-center gap-3 py-3">
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-semibold text-brand-ink">
                      {subject.name}
                    </p>
                    <p className="truncate text-xs text-brand-muted">
                      {subject.code} · {subject.major_name ?? 'Chưa gắn ngành'} ·{' '}
                      {subject.is_active ? 'Đang dùng' : 'Đã ẩn'}
                    </p>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => editSubject(subject)}
                  >
                    Sửa
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={activeMutation.isPending}
                    onClick={() =>
                      activeMutation.mutate({
                        kind: 'subject',
                        id: subject.id,
                        isActive: !subject.is_active,
                      })
                    }
                  >
                    {subject.is_active ? 'Ẩn' : 'Hiện'}
                  </Button>
                </div>
              ))}
              {subjects.length === 0 && (
                <p className="py-6 text-center text-sm text-brand-muted">
                  Chưa có môn học.
                </p>
              )}
            </div>
          </section>
        </div>
      )}
    </div>
  );
}
