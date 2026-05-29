-- Break The Glass // Supabase schema
-- Run this once in Supabase SQL Editor for project cvjuqwmdlrwirxztjgwo.
-- It creates private per-user challenge data with RLS enabled.

create extension if not exists pgcrypto;

create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  fear_text text not null check (char_length(fear_text) <= 500),
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.checkins (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  day_number int not null check (day_number between 1 and 7),
  entry_text text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (challenge_id, day_number)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.challenges(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  summary_text text not null,
  days_completed int not null default 0,
  word_count int not null default 0,
  longest_streak int not null default 0,
  created_at timestamptz not null default now(),
  unique (challenge_id)
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists challenges_set_updated_at on public.challenges;
create trigger challenges_set_updated_at
before update on public.challenges
for each row execute function public.set_updated_at();

drop trigger if exists checkins_set_updated_at on public.checkins;
create trigger checkins_set_updated_at
before update on public.checkins
for each row execute function public.set_updated_at();

alter table public.challenges enable row level security;
alter table public.checkins enable row level security;
alter table public.reports enable row level security;

-- Challenge policies
create policy "Users can read their own challenges"
  on public.challenges for select
  using (auth.uid() = user_id);

create policy "Users can insert their own challenges"
  on public.challenges for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own challenges"
  on public.challenges for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own challenges"
  on public.challenges for delete
  using (auth.uid() = user_id);

-- Check-in policies
create policy "Users can read their own checkins"
  on public.checkins for select
  using (auth.uid() = user_id);

create policy "Users can insert their own checkins"
  on public.checkins for insert
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.challenges
      where challenges.id = checkins.challenge_id
      and challenges.user_id = auth.uid()
    )
  );

create policy "Users can update their own checkins"
  on public.checkins for update
  using (auth.uid() = user_id)
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.challenges
      where challenges.id = checkins.challenge_id
      and challenges.user_id = auth.uid()
    )
  );

create policy "Users can delete their own checkins"
  on public.checkins for delete
  using (auth.uid() = user_id);

-- Report policies
create policy "Users can read their own reports"
  on public.reports for select
  using (auth.uid() = user_id);

create policy "Users can insert their own reports"
  on public.reports for insert
  with check (
    auth.uid() = user_id
    and exists (
      select 1 from public.challenges
      where challenges.id = reports.challenge_id
      and challenges.user_id = auth.uid()
    )
  );

create policy "Users can update their own reports"
  on public.reports for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists challenges_user_created_idx on public.challenges(user_id, created_at desc);
create index if not exists checkins_challenge_day_idx on public.checkins(challenge_id, day_number);
create index if not exists reports_user_created_idx on public.reports(user_id, created_at desc);
