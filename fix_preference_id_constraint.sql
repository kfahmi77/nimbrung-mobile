-- Fix preference_id constraint issues for registration

-- 1. Ensure preference_id column can be null
ALTER TABLE public.users 
ALTER COLUMN preference_id DROP NOT NULL;

-- 2. Remove any unique constraint on preference_id if it exists
-- (Users can share preferences or have null initially)
ALTER TABLE public.users 
DROP CONSTRAINT IF EXISTS users_preference_id_key;

-- 3. Check if there are any triggers that might auto-generate preference_id
-- If there are any triggers on the users table that auto-populate preference_id, 
-- they should be modified or dropped for initial registration

-- 4. Insert some default preferences if they don't exist
INSERT INTO public.preferences (id, preferences_name) VALUES 
  ('a1b2c3d4-e5f6-7890-1234-567890abcdef', 'Teknologi'),
  ('b2c3d4e5-f6g7-8901-2345-678901bcdefg', 'Sains'), 
  ('c3d4e5f6-g7h8-9012-3456-789012cdefgh', 'Sejarah'),
  ('d4e5f6g7-h8i9-0123-4567-890123defghi', 'Agama'),
  ('e5f6g7h8-i9j0-1234-5678-901234efghij', 'Umum')
ON CONFLICT (id) DO NOTHING;

-- 5. Ensure RLS policies allow null preference_id during registration
-- Update the insert policy to allow null preference_id
DROP POLICY IF EXISTS "Anyone can insert during registration" ON public.users;
CREATE POLICY "Anyone can insert during registration" ON public.users
  FOR INSERT 
  WITH CHECK (
    -- Allow registration with null preference_id
    preference_id IS NULL OR 
    -- Or if preference_id is provided, ensure it exists in preferences table
    preference_id IN (SELECT id FROM public.preferences)
  );

-- 6. Verify the foreign key constraint allows null values
-- This should already be the case, but let's make sure
SELECT 
  tc.table_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  tc.is_deferrable,
  tc.initially_deferred
FROM 
  information_schema.table_constraints AS tc 
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name='users' 
  AND kcu.column_name='preference_id';
