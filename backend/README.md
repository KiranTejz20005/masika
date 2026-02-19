# Backend

This folder holds all **backend** (server-side) code for Mashika.

## Purpose

- **API servers** – REST or GraphQL APIs
- **Supabase Edge Functions** – serverless functions
- **Workers / jobs** – scheduled or queue-based tasks
- **Shared backend logic** – validation, business rules, integrations

The Masika Flutter app in `frontend` uses Supabase from the client. Any logic that must run on the server belongs here.

## Structure (suggested)

You can organize by technology, for example:

```
backend/
├── functions/     # Supabase Edge Functions or other serverless
├── api/           # Optional REST/Node or other API
└── README.md
```

Or keep a single service in this folder and add more as needed.

## Supabase tables (patients & doctors)

The Flutter app expects two tables: **`patients`** (patient login) and **`doctors`** (doctor login).

1. In Supabase Dashboard → **SQL Editor**, run the script **`supabase_schema.sql`** in this folder.
2. That creates `public.patients` and `public.doctors` with RLS so each user can only read/update their own row.
3. For **immediate sign-in after register**, turn off **Auth → Providers → Email → “Confirm email”** in Supabase. Otherwise the profile row is created only after the user confirms and signs in.

## Adding more backend

1. Create a subfolder (e.g. `functions` for Edge Functions).
2. Add its own dependency file (`package.json`, etc.).
3. Document setup and deploy steps in this README or in the subfolder.
