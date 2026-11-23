create table if not exists public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id) on delete set null,
  target_user_id uuid references auth.users(id) on delete set null,
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists admin_audit_logs_target_created_idx
  on public.admin_audit_logs(target_user_id, created_at desc);
create index if not exists admin_audit_logs_actor_created_idx
  on public.admin_audit_logs(actor_id, created_at desc);

alter table public.admin_audit_logs enable row level security;

drop policy if exists admin_audit_logs_admin_read on public.admin_audit_logs;
create policy admin_audit_logs_admin_read
  on public.admin_audit_logs for select to authenticated
  using (public.is_admin_user());

grant select on public.admin_audit_logs to authenticated;

create or replace function public.is_active_user()
returns boolean
language sql
security definer
set search_path = public, pg_temp
stable
as $$
  select exists (
    select 1
      from public.profiles
     where id = auth.uid()
       and not is_locked
  );
$$;

revoke all on function public.is_active_user() from public;
grant execute on function public.is_active_user() to authenticated;

drop policy if exists active_user_gate_profiles on public.profiles;
create policy active_user_gate_profiles
  on public.profiles as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_subjects on public.subjects;
create policy active_user_gate_subjects
  on public.subjects as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_deadlines on public.deadlines;
create policy active_user_gate_deadlines
  on public.deadlines as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_quizzes on public.quizzes;
create policy active_user_gate_quizzes
  on public.quizzes as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_quiz_questions on public.quiz_questions;
create policy active_user_gate_quiz_questions
  on public.quiz_questions as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_quiz_options on public.quiz_options;
create policy active_user_gate_quiz_options
  on public.quiz_options as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_quiz_attempts on public.quiz_attempts;
create policy active_user_gate_quiz_attempts
  on public.quiz_attempts as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_attempt_answers on public.attempt_answers;
create policy active_user_gate_attempt_answers
  on public.attempt_answers as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_documents on public.documents;
create policy active_user_gate_documents
  on public.documents as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_document_progress on public.document_progress;
create policy active_user_gate_document_progress
  on public.document_progress as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_ai_plans on public.ai_plans;
create policy active_user_gate_ai_plans
  on public.ai_plans as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_reading_progress on public.reading_progress;
create policy active_user_gate_reading_progress
  on public.reading_progress as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_study_sessions on public.study_sessions;
create policy active_user_gate_study_sessions
  on public.study_sessions as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_ai_summaries on public.ai_summaries;
create policy active_user_gate_ai_summaries
  on public.ai_summaries as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_ai_chats on public.ai_chats;
create policy active_user_gate_ai_chats
  on public.ai_chats as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_ai_messages on public.ai_messages;
create policy active_user_gate_ai_messages
  on public.ai_messages as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_study_roadmaps on public.study_roadmaps;
create policy active_user_gate_study_roadmaps
  on public.study_roadmaps as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());
drop policy if exists active_user_gate_admin_audit_logs on public.admin_audit_logs;
create policy active_user_gate_admin_audit_logs
  on public.admin_audit_logs as restrictive for all to authenticated
  using (public.is_active_user())
  with check (public.is_active_user());

drop policy if exists active_user_gate_documents_storage on storage.objects;
create policy active_user_gate_documents_storage
  on storage.objects as restrictive for all to authenticated
  using (bucket_id <> 'documents' or public.is_active_user())
  with check (bucket_id <> 'documents' or public.is_active_user());

create or replace function public.protect_profile_security_fields()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if current_setting('vstudy.seed_mode', true) is distinct from 'on'
     and not public.is_admin_user() then
    if new.id <> old.id
       or new.email <> old.email
       or new.role <> old.role
       or new.is_locked <> old.is_locked
       or new.subjects <> old.subjects then
      raise exception 'Only an administrator can change protected profile fields';
    end if;
  end if;

  if auth.uid() = old.id
     and (new.role <> old.role or new.is_locked <> old.is_locked) then
    raise exception 'An administrator cannot change their own role or lock status';
  end if;

  return new;
end;
$$;

create or replace function public.admin_update_account(
  p_target_user_id uuid,
  p_role text,
  p_is_locked boolean
)
returns public.profiles
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  old_profile public.profiles%rowtype;
  updated_profile public.profiles%rowtype;
begin
  if auth.uid() is null or not public.is_admin_user() then
    raise exception 'Administrator access required';
  end if;

  if p_role not in ('STUDENT', 'ADMIN') then
    raise exception 'Invalid account role';
  end if;

  select *
    into old_profile
    from public.profiles
    where id = p_target_user_id
    for update;

  if not found then
    raise exception 'Account not found';
  end if;

  if p_target_user_id = auth.uid()
     and (p_role <> old_profile.role or p_is_locked <> old_profile.is_locked) then
    raise exception 'An administrator cannot change their own role or lock status';
  end if;

  update public.profiles
     set role = p_role,
         is_locked = p_is_locked
   where id = p_target_user_id
   returning * into updated_profile;

  if old_profile.role is distinct from updated_profile.role then
    insert into public.admin_audit_logs (
      actor_id, target_user_id, action, details
    )
    values (
      auth.uid(),
      p_target_user_id,
      'account.role_changed',
      jsonb_build_object('from', old_profile.role, 'to', updated_profile.role)
    );
  end if;

  if old_profile.is_locked is distinct from updated_profile.is_locked then
    insert into public.admin_audit_logs (
      actor_id, target_user_id, action, details
    )
    values (
      auth.uid(),
      p_target_user_id,
      'account.lock_status_changed',
      jsonb_build_object('from', old_profile.is_locked, 'to', updated_profile.is_locked)
    );
  end if;

  return updated_profile;
end;
$$;

revoke all on function public.admin_update_account(uuid, text, boolean) from public;
grant execute on function public.admin_update_account(uuid, text, boolean) to authenticated;

create or replace function public.admin_user_activity_summary(p_user_id uuid)
returns table (
  quiz_attempt_count bigint,
  recorded_study_minutes bigint,
  last_recorded_activity timestamptz
)
language plpgsql
security definer
stable
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null or not public.is_admin_user() then
    raise exception 'Administrator access required';
  end if;

  return query
  select
    (select count(*) from public.quiz_attempts qa where qa.owner_id = p_user_id),
    (select coalesce(sum(ss.duration_minutes), 0)::bigint
       from public.study_sessions ss where ss.user_id = p_user_id),
    greatest(
      (select max(ss.ended_at) from public.study_sessions ss where ss.user_id = p_user_id),
      (select max(qa.completed_at) from public.quiz_attempts qa where qa.owner_id = p_user_id),
      (select max(rp.last_opened_at) from public.reading_progress rp where rp.user_id = p_user_id)
    );
end;
$$;

revoke all on function public.admin_user_activity_summary(uuid) from public;
grant execute on function public.admin_user_activity_summary(uuid) to authenticated;

notify pgrst, 'reload schema';
