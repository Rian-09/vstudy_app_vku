-- V-STUDY profile schema.
-- Run this migration after enabling Supabase Auth.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  full_name text not null default '',
  class_name text not null default '',
  major text not null default '',
  birthday date,
  cohort text not null default '',
  subjects text[] not null default '{}',
  avatar_url text,
  role text not null default 'STUDENT'
    check (role in ('STUDENT', 'ADMIN')),
  is_locked boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_role_idx on public.profiles (role);
create index if not exists profiles_is_locked_idx on public.profiles (is_locked);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.is_admin_user()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid() and role = 'ADMIN' and not is_locked
  );
$$;

revoke all on function public.is_admin_user() from public;
grant execute on function public.is_admin_user() to authenticated;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do update
    set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Backfill profiles for Auth users created before this migration.
insert into public.profiles (id, email, full_name)
select
  id,
  coalesce(email, ''),
  coalesce(raw_user_meta_data ->> 'full_name', '')
from auth.users
on conflict (id) do nothing;

create or replace function public.protect_profile_security_fields()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- The seed script uses a locked-down transaction-local marker. It is only
  -- available while running as a database owner/service administrator and is
  -- never granted to the authenticated client role.
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
  return new;
end;
$$;

drop trigger if exists profiles_protect_security_fields on public.profiles;
create trigger profiles_protect_security_fields
before update on public.profiles
for each row execute function public.protect_profile_security_fields();

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own_or_admin" on public.profiles;
create policy "profiles_select_own_or_admin"
on public.profiles for select
to authenticated
using (id = auth.uid() or public.is_admin_user());

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "profiles_update_own_or_admin" on public.profiles;
create policy "profiles_update_own_or_admin"
on public.profiles for update
to authenticated
using (id = auth.uid() or public.is_admin_user())
with check (id = auth.uid() or public.is_admin_user());

grant select, insert, update on table public.profiles to authenticated;

notify pgrst, 'reload schema';
