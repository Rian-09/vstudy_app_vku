alter table public.quizzes
  add column if not exists shuffle_options boolean not null default true;

create or replace function public.admin_save_quiz(
  p_quiz_id uuid,
  p_subject_id uuid,
  p_title text,
  p_description text,
  p_duration_minutes integer,
  p_is_published boolean,
  p_mode text,
  p_questions jsonb,
  p_shuffle_options boolean
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_quiz_id uuid;
begin
  v_quiz_id := public.admin_save_quiz(
    p_quiz_id,
    p_subject_id,
    p_title,
    p_description,
    p_duration_minutes,
    p_is_published,
    p_mode,
    p_questions
  );

  update public.quizzes
     set shuffle_options = p_shuffle_options
   where id = v_quiz_id;

  return v_quiz_id;
end;
$$;

revoke all on function public.admin_save_quiz(
  uuid, uuid, text, text, integer, boolean, text, jsonb, boolean
) from public;
grant execute on function public.admin_save_quiz(
  uuid, uuid, text, text, integer, boolean, text, jsonb, boolean
) to authenticated;

notify pgrst, 'reload schema';
