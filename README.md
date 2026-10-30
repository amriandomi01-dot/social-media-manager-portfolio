# Socialbyamrian — Portfolio

A responsive dark portfolio website with a public project gallery and a private administrator workspace. Built with vanilla HTML/CSS/JS and Supabase Auth, Postgres and Storage.

## Features
- Public, no-login portfolio with category filters and responsive project cards.
- Private admin sign-in; only users explicitly assigned the `admin` role can manage content.
- Create, edit, publish/unpublish and delete projects.
- Upload images and MP4/WebM videos to Supabase Storage.
- Row Level Security protects unpublished projects and all write operations.

## Setup

### 1. Create Supabase project
Create a project at https://supabase.com. In **SQL Editor**, run all of `supabase/schema.sql`.

### 2. Create your admin account
In Supabase **Authentication → Users**, add your own user (email + password). Copy its UUID. Run:
```sql
insert into public.profiles (id, role)
values ('YOUR_AUTH_USER_UUID', 'admin');
```
Do not add public visitors to this table. Never expose a service-role key in the website.

### 3. Connect the website
In `index.html`, replace the empty `SUPABASE_URL` and `SUPABASE_ANON_KEY` constants with your Supabase project URL and anon/public key. These are designed for browser use; database and Storage access is constrained by the RLS policies in the SQL schema.

### 4. Publish
Deploy the repository to GitHub Pages, Netlify or Vercel. For GitHub Pages, enable Pages from the `main` branch root. The site is public; only the admin sign-in opens the private content studio.

## Notes
- Replace the placeholder email and social links in `index.html` with your preferred public contact details.
- Add projects through **Admin** at the bottom of the page after configuring Supabase.
- The storage bucket is public for media delivery, but only authorized admins can upload, update or delete objects.
- The initial portfolio copy and service descriptions are editable directly in `index.html`.
