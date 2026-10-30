-- Socialbyamrian portfolio: run this in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin' check (role in ('admin'))
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null check (category in ('Social Media','Content Creation','Branding','Digital Marketing','Web')),
  description text default '',
  media_url text,
  media_type text,
  published boolean not null default false,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create or replace function public.is_portfolio_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin') $$;
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
drop policy if exists "Admins can read own profile" on public.profiles;
create policy "Admins can read own profile" on public.profiles for select to authenticated using (id = auth.uid() and role = 'admin');
drop policy if exists "Public can read published projects" on public.projects;
create policy "Public can read published projects" on public.projects for select to anon, authenticated using (published = true or public.is_portfolio_admin());
drop policy if exists "Admins can insert projects" on public.projects;
create policy "Admins can insert projects" on public.projects for insert to authenticated with check (public.is_portfolio_admin() and created_by = auth.uid());
drop policy if exists "Admins can update projects" on public.projects;
create policy "Admins can update projects" on public.projects for update to authenticated using (public.is_portfolio_admin()) with check (public.is_portfolio_admin());
drop policy if exists "Admins can delete projects" on public.projects;
create policy "Admins can delete projects" on public.projects for delete to authenticated using (public.is_portfolio_admin());
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('portfolio-media','portfolio-media',true,104857600,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm'])
on conflict (id) do update set public=true, file_size_limit=104857600;
drop policy if exists "Public can view portfolio media" on storage.objects;
create policy "Public can view portfolio media" on storage.objects for select to anon, authenticated using (bucket_id='portfolio-media');
drop policy if exists "Admins can upload portfolio media" on storage.objects;
create policy "Admins can upload portfolio media" on storage.objects for insert to authenticated with check (bucket_id='portfolio-media' and public.is_portfolio_admin());
drop policy if exists "Admins can update portfolio media" on storage.objects;
create policy "Admins can update portfolio media" on storage.objects for update to authenticated using (bucket_id='portfolio-media' and public.is_portfolio_admin()) with check (bucket_id='portfolio-media' and public.is_portfolio_admin());
drop policy if exists "Admins can delete portfolio media" on storage.objects;
create policy "Admins can delete portfolio media" on storage.objects for delete to authenticated using (bucket_id='portfolio-media' and public.is_portfolio_admin());
-- After creating your administrator in Supabase Authentication, run:
-- insert into public.profiles (id, role) values ('YOUR_AUTH_USER_UUID', 'admin');
