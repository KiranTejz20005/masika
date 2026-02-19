-- Run this in Supabase Dashboard → SQL Editor to create tables for Masika.
-- Separate tables for patients (app users) and doctors.

-- Patients: for patient (user) registration and login
create table if not exists public.patients (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  age int not null default 25,
  language_code text not null default 'en',
  cycle_length int not null default 28,
  period_duration int not null default 5,
  email text,
  phone text,
  date_of_birth text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Doctors: for doctor registration and login
create table if not exists public.doctors (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  phone text default '',
  specialty text default '',
  registration_number text default '',
  clinic text default '',
  experience text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- RLS: allow users to read/update only their own row
alter table public.patients enable row level security;
alter table public.doctors enable row level security;

create policy "Users can read own patient row"
  on public.patients for select
  using (auth.uid() = id);

create policy "Users can update own patient row"
  on public.patients for update
  using (auth.uid() = id);

create policy "Users can insert own patient row"
  on public.patients for insert
  with check (auth.uid() = id);

create policy "Users can read own doctor row"
  on public.doctors for select
  using (auth.uid() = id);

create policy "Users can update own doctor row"
  on public.doctors for update
  using (auth.uid() = id);

create policy "Users can insert own doctor row"
  on public.doctors for insert
  with check (auth.uid() = id);

-- Optional: allow anonymous read of doctors list (e.g. for booking)
-- create policy "Anyone can list doctors"
--   on public.doctors for select
--   using (true);
