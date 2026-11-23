create table if not exists public.majors (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (length(trim(code)) > 0),
  name text not null check (length(trim(name)) > 0),
  description text not null default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.subjects
  add column if not exists major_id uuid
    references public.majors(id) on delete set null;

alter table public.document_folders
  add column if not exists major_id uuid
    references public.majors(id) on delete set null;

alter table public.documents
  add column if not exists major_id uuid
    references public.majors(id) on delete set null;

create index if not exists subjects_major_active_idx
  on public.subjects(major_id, is_active, name);
create index if not exists document_folders_major_idx
  on public.document_folders(major_id, name);
create index if not exists documents_major_created_idx
  on public.documents(major_id, created_at desc);

drop trigger if exists majors_set_updated_at on public.majors;
create trigger majors_set_updated_at
  before update on public.majors
  for each row execute function public.set_updated_at();

alter table public.majors enable row level security;

drop policy if exists majors_admin_read on public.majors;
create policy majors_admin_read
  on public.majors for select to authenticated
  using (is_active or public.is_admin_user());

drop policy if exists majors_admin_insert on public.majors;
create policy majors_admin_insert
  on public.majors for insert to authenticated
  with check (public.is_admin_user());

drop policy if exists majors_admin_update on public.majors;
create policy majors_admin_update
  on public.majors for update to authenticated
  using (public.is_admin_user())
  with check (public.is_admin_user());

drop policy if exists active_user_gate_majors on public.majors;
create policy active_user_gate_majors
  on public.majors as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());

grant select, insert, update on public.majors to authenticated;

notify pgrst, 'reload schema';
