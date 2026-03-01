-- migration_update_expenses_paid_by.sql

-- 1. If you need to update an EXISTING table:
-- Drop the old constraint referencing 'friends'
ALTER TABLE public.expenses
DROP CONSTRAINT IF EXISTS expenses_paid_by_fkey;

-- Add the new constraint referencing 'auth.users'
ALTER TABLE public.expenses
ADD CONSTRAINT expenses_paid_by_fkey
FOREIGN KEY (paid_by)
REFERENCES auth.users (id)
ON DELETE CASCADE;

-- 2. If you are creating the table from SCRATCH:
-- CREATE TABLE public.expenses (
--   id uuid not null default extensions.uuid_generate_v4 (),
--   trip_id uuid not null,
--   description text not null,
--   amount numeric not null,
--   paid_by uuid not null,
--   created_at timestamp with time zone not null default timezone ('utc'::text, now()),
--   constraint expenses_pkey primary key (id),
--   constraint expenses_paid_by_fkey foreign KEY (paid_by) references auth.users (id) on delete CASCADE,
--   constraint expenses_trip_id_fkey foreign KEY (trip_id) references trips (id) on delete CASCADE
-- ) TABLESPACE pg_default;
