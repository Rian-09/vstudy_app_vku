-- V-STUDY core schema: subjects, study management, quizzes, documents and AI plans.
-- Run after 202611070001_create_profiles.sql.

create extension if not exists pgcrypto;

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text not null default '',
  credits smallint not null default 0 check (credits >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.deadlines (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid references public.subjects(id) on delete set null,
  title text not null check (length(trim(title)) > 0),
  description text not null default '',
  due_at timestamptz not null,
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  status text not null default 'todo' check (status in ('todo', 'in_progress', 'done')),
  reminder_1d_sent boolean not null default false,
  reminder_1h_sent boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  title text not null check (length(trim(title)) > 0),
  description text not null default '',
  duration_minutes integer not null default 30 check (duration_minutes > 0),
  is_published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  question_text text not null check (length(trim(question_text)) > 0),
  explanation text not null default '',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  option_text text not null check (length(trim(option_text)) > 0),
  option_index smallint not null check (option_index between 0 and 3),
  is_correct boolean not null default false,
  created_at timestamptz not null default now(),
  unique (question_id, option_index)
);

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  score numeric(5, 2) check (score between 0 and 100),
  correct_count integer not null default 0 check (correct_count >= 0),
  wrong_count integer not null default 0 check (wrong_count >= 0),
  skipped_count integer not null default 0 check (skipped_count >= 0),
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.attempt_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid not null references public.quiz_attempts(id) on delete cascade,
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  selected_option_index smallint check (selected_option_index between 0 and 3),
  is_correct boolean,
  created_at timestamptz not null default now(),
  unique (attempt_id, question_id)
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references public.subjects(id) on delete set null,
  title text not null check (length(trim(title)) > 0),
  description text not null default '',
  category text not null default 'course' check (category in ('course', 'exam', 'review')),
  file_path text not null,
  file_type text not null,
  file_size_bytes bigint check (file_size_bytes is null or file_size_bytes >= 0),
  page_count integer check (page_count is null or page_count > 0),
  thumbnail_path text,
  is_published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.document_progress (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  document_id uuid not null references public.documents(id) on delete cascade,
  progress numeric(5, 4) not null default 0 check (progress between 0 and 1),
  is_saved boolean not null default false,
  is_downloaded boolean not null default false,
  updated_at timestamptz not null default now(),
  unique (owner_id, document_id)
);

create table if not exists public.ai_plans (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (length(trim(title)) > 0),
  plan_json jsonb not null,
  source_snapshot jsonb not null default '{}'::jsonb,
  status text not null default 'active' check (status in ('active', 'completed', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists deadlines_owner_due_idx on public.deadlines(owner_id, due_at);
create index if not exists deadlines_owner_status_idx on public.deadlines(owner_id, status);
create index if not exists deadlines_subject_idx on public.deadlines(subject_id);
create index if not exists quizzes_subject_published_idx on public.quizzes(subject_id, is_published);
create index if not exists quiz_questions_quiz_order_idx on public.quiz_questions(quiz_id, sort_order);
create index if not exists quiz_options_question_idx on public.quiz_options(question_id);
create index if not exists quiz_attempts_owner_created_idx on public.quiz_attempts(owner_id, created_at desc);
create index if not exists quiz_attempts_quiz_idx on public.quiz_attempts(quiz_id);
create index if not exists attempt_answers_attempt_idx on public.attempt_answers(attempt_id);
create index if not exists documents_subject_category_idx on public.documents(subject_id, category);
create index if not exists documents_published_idx on public.documents(is_published);
create index if not exists document_progress_owner_idx on public.document_progress(owner_id);
create index if not exists ai_plans_owner_updated_idx on public.ai_plans(owner_id, updated_at desc);

drop trigger if exists subjects_set_updated_at on public.subjects;
create trigger subjects_set_updated_at before update on public.subjects
for each row execute function public.set_updated_at();
drop trigger if exists deadlines_set_updated_at on public.deadlines;
create trigger deadlines_set_updated_at before update on public.deadlines
for each row execute function public.set_updated_at();
drop trigger if exists quizzes_set_updated_at on public.quizzes;
create trigger quizzes_set_updated_at before update on public.quizzes
for each row execute function public.set_updated_at();
drop trigger if exists quiz_questions_set_updated_at on public.quiz_questions;
create trigger quiz_questions_set_updated_at before update on public.quiz_questions
for each row execute function public.set_updated_at();
drop trigger if exists documents_set_updated_at on public.documents;
create trigger documents_set_updated_at before update on public.documents
for each row execute function public.set_updated_at();
drop trigger if exists document_progress_set_updated_at on public.document_progress;
create trigger document_progress_set_updated_at before update on public.document_progress
for each row execute function public.set_updated_at();
drop trigger if exists ai_plans_set_updated_at on public.ai_plans;
create trigger ai_plans_set_updated_at before update on public.ai_plans
for each row execute function public.set_updated_at();

alter table public.subjects enable row level security;
alter table public.deadlines enable row level security;
alter table public.quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_options enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.attempt_answers enable row level security;
alter table public.documents enable row level security;
alter table public.document_progress enable row level security;
alter table public.ai_plans enable row level security;

drop policy if exists subjects_read_active on public.subjects;
create policy subjects_read_active on public.subjects for select to authenticated
using (is_active or public.is_admin_user());
drop policy if exists subjects_admin_insert on public.subjects;
create policy subjects_admin_insert on public.subjects for insert to authenticated
with check (public.is_admin_user());
drop policy if exists subjects_admin_update on public.subjects;
create policy subjects_admin_update on public.subjects for update to authenticated
using (public.is_admin_user()) with check (public.is_admin_user());
drop policy if exists subjects_admin_delete on public.subjects;
create policy subjects_admin_delete on public.subjects for delete to authenticated
using (public.is_admin_user());

drop policy if exists deadlines_owner_read on public.deadlines;
create policy deadlines_owner_read on public.deadlines for select to authenticated
using (owner_id = auth.uid() or public.is_admin_user());
drop policy if exists deadlines_owner_insert on public.deadlines;
create policy deadlines_owner_insert on public.deadlines for insert to authenticated
with check (owner_id = auth.uid() or public.is_admin_user());
drop policy if exists deadlines_owner_update on public.deadlines;
create policy deadlines_owner_update on public.deadlines for update to authenticated
using (owner_id = auth.uid() or public.is_admin_user())
with check (owner_id = auth.uid() or public.is_admin_user());
drop policy if exists deadlines_owner_delete on public.deadlines;
create policy deadlines_owner_delete on public.deadlines for delete to authenticated
using (owner_id = auth.uid() or public.is_admin_user());

drop policy if exists quizzes_read_published on public.quizzes;
create policy quizzes_read_published on public.quizzes for select to authenticated
using (is_published or public.is_admin_user());
drop policy if exists quizzes_admin_insert on public.quizzes;
create policy quizzes_admin_insert on public.quizzes for insert to authenticated
with check (public.is_admin_user());
drop policy if exists quizzes_admin_update on public.quizzes;
create policy quizzes_admin_update on public.quizzes for update to authenticated
using (public.is_admin_user()) with check (public.is_admin_user());
drop policy if exists quizzes_admin_delete on public.quizzes;
create policy quizzes_admin_delete on public.quizzes for delete to authenticated
using (public.is_admin_user());

drop policy if exists quiz_questions_read_published on public.quiz_questions;
create policy quiz_questions_read_published on public.quiz_questions for select to authenticated
using (exists (select 1 from public.quizzes q where q.id = quiz_id and (q.is_published or public.is_admin_user())));
drop policy if exists quiz_questions_admin_write on public.quiz_questions;
create policy quiz_questions_admin_write on public.quiz_questions for all to authenticated
using (public.is_admin_user()) with check (public.is_admin_user());

drop policy if exists quiz_options_read_published on public.quiz_options;
create policy quiz_options_read_published on public.quiz_options for select to authenticated
using (exists (
  select 1 from public.quiz_questions qq
  join public.quizzes q on q.id = qq.quiz_id
  where qq.id = question_id and (q.is_published or public.is_admin_user())
));
drop policy if exists quiz_options_admin_write on public.quiz_options;
create policy quiz_options_admin_write on public.quiz_options for all to authenticated
using (public.is_admin_user()) with check (public.is_admin_user());

drop policy if exists quiz_attempts_owner_read on public.quiz_attempts;
create policy quiz_attempts_owner_read on public.quiz_attempts for select to authenticated
using (owner_id = auth.uid() or public.is_admin_user());
drop policy if exists quiz_attempts_owner_insert on public.quiz_attempts;
create policy quiz_attempts_owner_insert on public.quiz_attempts for insert to authenticated
with check (owner_id = auth.uid());
drop policy if exists quiz_attempts_owner_update on public.quiz_attempts;
create policy quiz_attempts_owner_update on public.quiz_attempts for update to authenticated
using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists attempt_answers_owner_read on public.attempt_answers;
create policy attempt_answers_owner_read on public.attempt_answers for select to authenticated
using (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and (a.owner_id = auth.uid() or public.is_admin_user())));
drop policy if exists attempt_answers_owner_insert on public.attempt_answers;
create policy attempt_answers_owner_insert on public.attempt_answers for insert to authenticated
with check (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and a.owner_id = auth.uid()));
drop policy if exists attempt_answers_owner_update on public.attempt_answers;
create policy attempt_answers_owner_update on public.attempt_answers for update to authenticated
using (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and a.owner_id = auth.uid()))
with check (exists (select 1 from public.quiz_attempts a where a.id = attempt_id and a.owner_id = auth.uid()));

drop policy if exists documents_read_published on public.documents;
create policy documents_read_published on public.documents for select to authenticated
using (is_published or public.is_admin_user());
drop policy if exists documents_admin_insert on public.documents;
create policy documents_admin_insert on public.documents for insert to authenticated
with check (public.is_admin_user());
drop policy if exists documents_admin_update on public.documents;
create policy documents_admin_update on public.documents for update to authenticated
using (public.is_admin_user()) with check (public.is_admin_user());
drop policy if exists documents_admin_delete on public.documents;
create policy documents_admin_delete on public.documents for delete to authenticated
using (public.is_admin_user());

drop policy if exists document_progress_owner_read on public.document_progress;
create policy document_progress_owner_read on public.document_progress for select to authenticated
using (owner_id = auth.uid() or public.is_admin_user());
drop policy if exists document_progress_owner_insert on public.document_progress;
create policy document_progress_owner_insert on public.document_progress for insert to authenticated
with check (owner_id = auth.uid());
drop policy if exists document_progress_owner_update on public.document_progress;
create policy document_progress_owner_update on public.document_progress for update to authenticated
using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists document_progress_owner_delete on public.document_progress;
create policy document_progress_owner_delete on public.document_progress for delete to authenticated
using (owner_id = auth.uid());

drop policy if exists ai_plans_owner_read on public.ai_plans;
create policy ai_plans_owner_read on public.ai_plans for select to authenticated
using (owner_id = auth.uid() or public.is_admin_user());
drop policy if exists ai_plans_owner_insert on public.ai_plans;
create policy ai_plans_owner_insert on public.ai_plans for insert to authenticated
with check (owner_id = auth.uid());
drop policy if exists ai_plans_owner_update on public.ai_plans;
create policy ai_plans_owner_update on public.ai_plans for update to authenticated
using (owner_id = auth.uid()) with check (owner_id = auth.uid());
drop policy if exists ai_plans_owner_delete on public.ai_plans;
create policy ai_plans_owner_delete on public.ai_plans for delete to authenticated
using (owner_id = auth.uid());

grant select, insert, update, delete on public.subjects to authenticated;
grant select, insert, update, delete on public.deadlines to authenticated;
grant select, insert, update, delete on public.quizzes to authenticated;
grant select, insert, update, delete on public.quiz_questions to authenticated;
grant select, insert, update, delete on public.quiz_options to authenticated;
grant select, insert, update on public.quiz_attempts to authenticated;
grant select, insert, update on public.attempt_answers to authenticated;
grant select, insert, update, delete on public.documents to authenticated;
grant select, insert, update, delete on public.document_progress to authenticated;
grant select, insert, update, delete on public.ai_plans to authenticated;

notify pgrst, 'reload schema';
