-- Fix the database schema for the registration flow

-- 1. Make preference_id nullable in users table since it's not required during initial registration
ALTER TABLE public.users 
ALTER COLUMN preference_id DROP NOT NULL;

-- 2. Make preference_id not unique since users can share preferences or have null preferences initially
ALTER TABLE public.users 
DROP CONSTRAINT users_preference_id_key;

-- 3. Add some default preferences for users to choose from later
INSERT INTO public.preferences (preferences_name) VALUES 
  ('Teknologi'),
  ('Sains'), 
  ('Sejarah'),
  ('Agama'),
  ('Umum')
ON CONFLICT DO NOTHING;

-- 4. Set up Row Level Security (RLS) policies if not already done
-- Enable RLS on tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auth_provider ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users  
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Anyone can insert during registration" ON public.users
  FOR INSERT WITH CHECK (true);

-- Create policies for preferences table  
CREATE POLICY "Anyone can view preferences" ON public.preferences
  FOR SELECT TO authenticated, anon USING (true);

-- Create policies for auth_provider table
CREATE POLICY "Users can view own auth providers" ON public.auth_provider
  FOR ALL USING (auth.uid() = provider_user_id);

-- Note: Make sure Supabase Auth is properly configured to allow user registration
-- You might need to adjust these policies based on your specific security requirements
