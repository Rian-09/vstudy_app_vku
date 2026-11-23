create table if not exists public.document_folders (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  subject_id uuid references public.subjects(id) on delete set null,
  semester text not null default '',
  parent_folder_id uuid references public.document_folders(id) on delete restrict,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint document_folders_not_own_parent check (
    parent_folder_id is null or parent_folder_id <> id
  )
);

alter table public.documents
  add column if not exists folder_id uuid
    references public.document_folders(id) on delete restrict,
  add column if not exists tags text[] not null default '{}';

create index if not exists document_folders_parent_idx
  on public.document_folders(parent_folder_id, name);
create index if not exists document_folders_subject_semester_idx
  on public.document_folders(subject_id, semester);
create index if not exists documents_folder_idx
  on public.documents(folder_id, created_at desc);
create index if not exists documents_tags_idx
  on public.documents using gin(tags);

drop trigger if exists document_folders_set_updated_at on public.document_folders;
create trigger document_folders_set_updated_at
  before update on public.document_folders
  for each row execute function public.set_updated_at();

create or replace function public.prevent_document_folder_cycle()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  creates_cycle boolean;
begin
  if new.parent_folder_id is null then
    return new;
  end if;

  if new.parent_folder_id = new.id then
    raise exception 'A folder cannot be its own parent';
  end if;

  with recursive ancestors(id, parent_folder_id) as (
    select id, parent_folder_id
      from public.document_folders
     where id = new.parent_folder_id
    union
    select folder.id, folder.parent_folder_id
      from public.document_folders folder
      join ancestors on folder.id = ancestors.parent_folder_id
  )
  select exists (
    select 1 from ancestors where id = new.id
  )
  into creates_cycle;

  if creates_cycle then
    raise exception 'Moving this folder would create a folder cycle';
  end if;

  return new;
end;
$$;

drop trigger if exists document_folders_prevent_cycle on public.document_folders;
create trigger document_folders_prevent_cycle
  before insert or update on public.document_folders
  for each row execute function public.prevent_document_folder_cycle();

alter table public.document_folders enable row level security;

drop policy if exists document_folders_admin_read on public.document_folders;
create policy document_folders_admin_read
  on public.document_folders for select to authenticated
  using (public.is_admin_user());
drop policy if exists document_folders_admin_insert on public.document_folders;
create policy document_folders_admin_insert
  on public.document_folders for insert to authenticated
  with check (public.is_admin_user());
drop policy if exists document_folders_admin_update on public.document_folders;
create policy document_folders_admin_update
  on public.document_folders for update to authenticated
  using (public.is_admin_user())
  with check (public.is_admin_user());
drop policy if exists document_folders_admin_delete on public.document_folders;
create policy document_folders_admin_delete
  on public.document_folders for delete to authenticated
  using (public.is_admin_user());

drop policy if exists active_user_gate_document_folders
  on public.document_folders;
create policy active_user_gate_document_folders
  on public.document_folders as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());

grant select, insert, update, delete on public.document_folders to authenticated;

notify pgrst, 'reload schema';
