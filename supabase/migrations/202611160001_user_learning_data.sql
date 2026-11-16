-- User-owned learning data. This migration is additive so existing catalog,
-- quiz, schedule, and progress data remains available during the transition.

alter table public.profiles
  add column if not exists full_name text,
  add column if not exists avatar_url text;

-- Published documents remain a shared catalog; user_id owns private uploads.
alter table public.documents
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists subject text,
  add column if not exists file_size bigint,
  add column if not exists extracted_text text;

update public.documents
set file_size = file_size_bytes
where file_size is null and file_size_bytes is not null;

alter table public.documents
  drop constraint if exists documents_file_size_nonnegative;
alter table public.documents
  add constraint documents_file_size_nonnegative
  check (file_size is null or file_size >= 0);

create table if not exists public.reading_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  document_id uuid not null references public.documents(id) on delete cascade,
  current_page integer not null default 0 check (current_page >= 0),
  total_pages integer not null default 0 check (total_pages >= 0),
  percent numeric(5, 2) not null default 0 check (percent between 0 and 100),
  last_opened_at timestamptz not null default now(),
  is_finished boolean not null default false,
  unique (user_id, document_id)
);

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  document_id uuid references public.documents(id) on delete set null,
  subject text,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_minutes integer not null default 0 check (duration_minutes >= 0),
  activity_type text not null check (activity_type in ('read', 'summary', 'qa', 'quiz'))
);

create table if not exists public.ai_summaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  document_id uuid references public.documents(id) on delete set null,
  source_type text not null check (source_type in ('saved', 'uploaded')),
  source_name text not null,
  content text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.ai_chats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  document_id uuid references public.documents(id) on delete set null,
  title text not null default 'Cuộc trò chuyện mới',
  created_at timestamptz not null default now(),
  unique (id, user_id)
);

create table if not exists public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  chat_id uuid not null references public.ai_chats(id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  created_at timestamptz not null default now(),
  constraint ai_messages_chat_user_fk
    foreign key (chat_id, user_id)
    references public.ai_chats(id, user_id)
    on delete cascade
);

create table if not exists public.study_roadmaps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal text not null,
  content jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  based_on_stats jsonb not null default '{}'::jsonb
);

create index if not exists documents_user_created_idx
  on public.documents(user_id, created_at desc) where user_id is not null;
create index if not exists reading_progress_user_opened_idx
  on public.reading_progress(user_id, last_opened_at desc);
create index if not exists study_sessions_user_started_idx
  on public.study_sessions(user_id, started_at desc);
create index if not exists ai_summaries_user_created_idx
  on public.ai_summaries(user_id, created_at desc);
create index if not exists ai_chats_user_created_idx
  on public.ai_chats(user_id, created_at desc);
create index if not exists ai_messages_chat_created_idx
  on public.ai_messages(user_id, chat_id, created_at);
create index if not exists study_roadmaps_user_created_idx
  on public.study_roadmaps(user_id, created_at desc);

alter table public.reading_progress enable row level security;
alter table public.study_sessions enable row level security;
alter table public.ai_summaries enable row level security;
alter table public.ai_chats enable row level security;
alter table public.ai_messages enable row level security;
alter table public.study_roadmaps enable row level security;

-- Private document rows belong to their uploader; published catalog rows remain readable.
drop policy if exists documents_read_published on public.documents;
drop policy if exists documents_admin_insert on public.documents;
drop policy if exists documents_admin_update on public.documents;
drop policy if exists documents_admin_delete on public.documents;
create policy documents_read_owner_or_published on public.documents
  for select to authenticated
  using (user_id = auth.uid() or is_published or public.is_admin_user());
create policy documents_insert_owner on public.documents
  for insert to authenticated
  with check (
    public.is_admin_user()
    or (
      user_id = auth.uid()
      and (storage.foldername(file_path))[1] = auth.uid()::text
    )
  );
create policy documents_update_owner on public.documents
  for update to authenticated
  using (user_id = auth.uid() or public.is_admin_user())
  with check (
    public.is_admin_user()
    or (
      user_id = auth.uid()
      and (storage.foldername(file_path))[1] = auth.uid()::text
    )
  );
create policy documents_delete_owner on public.documents
  for delete to authenticated
  using (user_id = auth.uid() or public.is_admin_user());

create policy reading_progress_owner_all on public.reading_progress
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.documents d
      where d.id = document_id and (d.user_id = auth.uid() or d.is_published)
    )
  );
create policy study_sessions_owner_all on public.study_sessions
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and (document_id is null or exists (
      select 1 from public.documents d
      where d.id = document_id and (d.user_id = auth.uid() or d.is_published)
    ))
  );
create policy ai_summaries_owner_all on public.ai_summaries
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and (document_id is null or exists (
      select 1 from public.documents d
      where d.id = document_id and (d.user_id = auth.uid() or d.is_published)
    ))
  );
create policy ai_chats_owner_all on public.ai_chats
  for all to authenticated
  using (user_id = auth.uid())
  with check (
    user_id = auth.uid()
    and (document_id is null or exists (
      select 1 from public.documents d
      where d.id = document_id and (d.user_id = auth.uid() or d.is_published)
    ))
  );
create policy ai_messages_owner_all on public.ai_messages
  for all to authenticated
  using (
    user_id = auth.uid()
    and exists (select 1 from public.ai_chats c where c.id = chat_id and c.user_id = auth.uid())
  )
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.ai_chats c where c.id = chat_id and c.user_id = auth.uid())
  );
create policy study_roadmaps_owner_all on public.study_roadmaps
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select, insert, update, delete on public.documents to authenticated;
grant select, insert, update, delete on public.reading_progress to authenticated;
grant select, insert, update, delete on public.study_sessions to authenticated;
grant select, insert, update, delete on public.ai_summaries to authenticated;
grant select, insert, update, delete on public.ai_chats to authenticated;
grant select, insert, update, delete on public.ai_messages to authenticated;
grant select, insert, update, delete on public.study_roadmaps to authenticated;

-- Storage object names must begin with the authenticated user's UUID.
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do update set public = false;

drop policy if exists documents_storage_read on storage.objects;
drop policy if exists documents_storage_admin_insert on storage.objects;
drop policy if exists documents_storage_admin_update on storage.objects;
drop policy if exists documents_storage_admin_delete on storage.objects;
create policy documents_storage_read_owner_or_published on storage.objects
  for select to authenticated
  using (
    bucket_id = 'documents'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_admin_user()
      or exists (
        select 1 from public.documents d
        where d.file_path = name and d.is_published
      )
    )
  );
create policy documents_storage_insert_owner on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'documents'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin_user())
  );
create policy documents_storage_update_owner on storage.objects
  for update to authenticated
  using (
    bucket_id = 'documents'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin_user())
  )
  with check (
    bucket_id = 'documents'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin_user())
  );
create policy documents_storage_delete_owner on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'documents'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin_user())
  );

notify pgrst, 'reload schema';
