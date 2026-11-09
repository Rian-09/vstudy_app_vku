-- Store both deadlines and calendar sessions in the owner-scoped deadlines table.
-- Run after 202611090002_create_core_schema.sql.

alter table public.deadlines
  add column if not exists event_type text not null default 'deadline'
    check (event_type in ('classSession', 'deadline', 'selfStudy', 'free')),
  add column if not exists event_format text not null default 'free'
    check (event_format in ('inClass', 'selfStudy', 'online', 'free')),
  add column if not exists starts_at timestamptz not null default now(),
  add column if not exists ends_at timestamptz not null default now(),
  add column if not exists subject_name text not null default '',
  add column if not exists location text not null default '',
  add column if not exists repeat_rule text not null default 'Không lặp lại',
  add column if not exists reminder_label text not null default 'Không nhắc trước',
  add column if not exists checklist jsonb not null default '[]'::jsonb;

create index if not exists deadlines_owner_starts_at_idx
  on public.deadlines(owner_id, starts_at);

notify pgrst, 'reload schema';
