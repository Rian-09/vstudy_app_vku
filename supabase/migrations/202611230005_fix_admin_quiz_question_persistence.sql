create or replace function public.admin_save_quiz(
  p_quiz_id uuid,
  p_subject_id uuid,
  p_title text,
  p_description text,
  p_duration_minutes integer,
  p_is_published boolean,
  p_mode text,
  p_questions jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_quiz_id uuid;
  v_question jsonb;
  v_option jsonb;
  v_question_id uuid;
  v_question_id_text text;
  v_question_text text;
  v_options jsonb;
  v_correct_index integer;
  v_option_index integer;
  v_sort_order integer := 0;
  v_question_count integer;
  v_saved_question_ids uuid[] := array[]::uuid[];
begin
  if auth.uid() is null or not public.is_admin_user() then
    raise exception 'Administrator access required';
  end if;

  if p_title is null or length(trim(p_title)) = 0 then
    raise exception 'Quiz title is required';
  end if;
  if p_mode is null or p_mode not in ('practice', 'exam') then
    raise exception 'Invalid quiz mode';
  end if;
  if p_duration_minutes is null or p_duration_minutes <= 0 then
    raise exception 'Quiz duration must be positive';
  end if;
  if p_questions is null or jsonb_typeof(p_questions) is distinct from 'array' then
    raise exception 'Questions must be an array';
  end if;
  if p_is_published and jsonb_array_length(p_questions) = 0 then
    raise exception 'A published quiz must contain at least one question';
  end if;
  if not exists (
    select 1 from public.subjects
     where id = p_subject_id and is_active
  ) then
    raise exception 'An active subject is required';
  end if;

  if p_quiz_id is null then
    insert into public.quizzes (
      subject_id, title, description, duration_minutes, is_published, mode,
      created_by
    )
    values (
      p_subject_id, trim(p_title), coalesce(p_description, ''),
      p_duration_minutes, p_is_published, p_mode, auth.uid()
    )
    returning id into v_quiz_id;
  else
    select id into v_quiz_id
      from public.quizzes
     where id = p_quiz_id
     for update;
    if not found then
      raise exception 'Quiz not found';
    end if;

    update public.quizzes
       set subject_id = p_subject_id,
           title = trim(p_title),
           description = coalesce(p_description, ''),
           duration_minutes = p_duration_minutes,
           is_published = p_is_published,
           mode = p_mode
     where id = v_quiz_id;
  end if;

  for v_question in
    select value from jsonb_array_elements(p_questions)
  loop
    v_question_text := nullif(trim(v_question->>'questionText'), '');
    v_options := v_question->'options';
    if v_question_text is null then
      raise exception 'Question text cannot be empty';
    end if;
    if jsonb_typeof(v_options) is distinct from 'array'
       or jsonb_array_length(v_options) <> 4 then
      raise exception 'Each question must have exactly four options';
    end if;
    if jsonb_typeof(v_question->'correctIndex') is distinct from 'number' then
      raise exception 'Each question must have a correct option index';
    end if;
    v_correct_index := (v_question->>'correctIndex')::integer;
    if v_correct_index < 0 or v_correct_index > 3 then
      raise exception 'Correct option index must be between 0 and 3';
    end if;

    v_question_id_text := nullif(v_question->>'id', '');
    if v_question_id_text is null then
      insert into public.quiz_questions (
        quiz_id, question_text, explanation, sort_order
      )
      values (
        v_quiz_id,
        v_question_text,
        coalesce(v_question->>'explanation', ''),
        v_sort_order
      )
      returning id into v_question_id;
    else
      begin
        v_question_id := v_question_id_text::uuid;
      exception when invalid_text_representation then
        raise exception 'Invalid question id';
      end;

      update public.quiz_questions
         set question_text = v_question_text,
             explanation = coalesce(v_question->>'explanation', ''),
             sort_order = v_sort_order
       where id = v_question_id
         and quiz_id = v_quiz_id;
      if not found then
        raise exception 'Question does not belong to this quiz';
      end if;
    end if;
    v_saved_question_ids := array_append(v_saved_question_ids, v_question_id);

    v_option_index := 0;
    for v_option in
      select value from jsonb_array_elements(v_options)
    loop
      if jsonb_typeof(v_option) is distinct from 'string'
         or length(trim(v_option #>> '{}')) = 0 then
        raise exception 'Question options cannot be empty';
      end if;

      insert into public.quiz_options (
        question_id, option_text, option_index, is_correct
      )
      values (
        v_question_id,
        v_option #>> '{}',
        v_option_index,
        v_option_index = v_correct_index
      )
      on conflict (question_id, option_index)
      do update set
        option_text = excluded.option_text,
        is_correct = excluded.is_correct;

      v_option_index := v_option_index + 1;
    end loop;

    v_sort_order := v_sort_order + 1;
  end loop;

  if exists (
    select 1
      from public.quiz_questions qq
     where qq.quiz_id = v_quiz_id
       and not (qq.id = any(v_saved_question_ids))
       and (
         exists (
           select 1
             from public.attempt_answers aa
            where aa.question_id = qq.id
         )
         or exists (
           select 1
             from public.quiz_attempts qa
            where qa.quiz_id = v_quiz_id
              and qa.completed_at is null
         )
       )
  ) then
    raise exception 'Questions with submitted answers or active attempts cannot be deleted';
  end if;

  delete from public.quiz_questions qq
   where qq.quiz_id = v_quiz_id
     and not (qq.id = any(v_saved_question_ids));

  v_question_count := jsonb_array_length(p_questions);
  insert into public.admin_audit_logs (
    actor_id, action, details
  )
  values (
    auth.uid(),
    case when p_quiz_id is null then 'quiz.created' else 'quiz.updated' end,
    jsonb_build_object(
      'quiz_id', v_quiz_id,
      'title', trim(p_title),
      'mode', p_mode,
      'is_published', p_is_published,
      'question_count', v_question_count
    )
  );

  return v_quiz_id;
end;
$$;

revoke all on function public.admin_save_quiz(
  uuid, uuid, text, text, integer, boolean, text, jsonb
) from public;
grant execute on function public.admin_save_quiz(
  uuid, uuid, text, text, integer, boolean, text, jsonb
) to authenticated;

notify pgrst, 'reload schema';
