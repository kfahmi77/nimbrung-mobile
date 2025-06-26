-- Fix Row Level Security policies for user registration

-- Drop existing policies that might be conflicting
DROP POLICY IF EXISTS "Users can access their own data" ON public.users;
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Anyone can insert during registration" ON public.users;

-- Create new, more permissive policies for registration flow
-- Allow anyone to insert during registration (this is needed for signUp flow)
CREATE POLICY "Enable insert for registration" ON public.users
  FOR INSERT WITH CHECK (true);

-- Allow users to view their own profile after authentication
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile after authentication  
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Optional: Allow service role to manage all users (for admin functions)
CREATE POLICY "Service role can manage all users" ON public.users
  FOR ALL USING (auth.role() = 'service_role');

-- Verify RLS is enabled
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Also fix preferences policies to be more permissive
DROP POLICY IF EXISTS "Anyone can view preferences" ON public.preferences;
CREATE POLICY "Anyone can view preferences" ON public.preferences
  FOR SELECT TO authenticated, anon USING (true);

-- Fix auth_provider policies
DROP POLICY IF EXISTS "Users can view own auth providers" ON public.auth_provider;
CREATE POLICY "Users can manage own auth providers" ON public.auth_provider
  FOR ALL USING (auth.uid() = provider_user_id);

-- Enable insert for auth providers during registration
CREATE POLICY "Enable insert for auth providers" ON public.auth_provider
  FOR INSERT WITH CHECK (true);
