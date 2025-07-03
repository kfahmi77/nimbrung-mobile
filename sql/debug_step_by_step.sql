-- SIMPLE TEST SCRIPT - Run each section step by step in Supabase SQL Editor
-- This will help us identify exactly what's wrong

-- ============================================================================
-- TEST 1: Check if the function exists
-- ============================================================================
SELECT 'Testing if get_today_reading function exists...' as test;

SELECT proname as function_name 
FROM pg_proc 
WHERE proname = 'get_today_reading';

-- If this returns no rows, the function doesn't exist
-- If this returns a row, the function exists

-- ============================================================================
-- TEST 2: Check basic tables and data
-- ============================================================================
SELECT 'Testing basic table structure...' as test;

-- Check if we have users
SELECT 'users table' as table_name, COUNT(*) as row_count FROM users;

-- Check if we have preferences  
SELECT 'preferences table' as table_name, COUNT(*) as row_count FROM preferences;

-- Check if we have reading_subjects
SELECT 'reading_subjects table' as table_name, COUNT(*) as row_count FROM reading_subjects;

-- Check if we have daily_readings
SELECT 'daily_readings table' as table_name, COUNT(*) as row_count FROM daily_readings;

-- ============================================================================
-- TEST 3: Get a real user ID to test with
-- ============================================================================
SELECT 'Getting sample user IDs...' as test;

SELECT id, email, preference_id, username 
FROM users 
WHERE preference_id IS NOT NULL 
LIMIT 5;

-- ============================================================================
-- TEST 4: Test the function with a real user ID
-- ============================================================================
-- Copy a user ID from TEST 3 and replace 'YOUR_USER_ID_HERE' below:

-- SELECT 'Testing get_today_reading function...' as test;
-- SELECT * FROM get_today_reading('YOUR_USER_ID_HERE'::uuid);

-- ============================================================================
-- TEST 5: Check RLS policies (if the function works but app still fails)
-- ============================================================================
SELECT 'Checking RLS policies...' as test;

SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename IN ('users', 'reading_subjects', 'daily_readings', 'user_reading_progress', 'reading_completions')
ORDER BY tablename, policyname;

-- ============================================================================
-- INSTRUCTIONS:
-- ============================================================================
-- 1. Run TEST 1 - if no function found, re-run the rpc_functions_only.sql
-- 2. Run TEST 2 - all tables should have some data
-- 3. Run TEST 3 - you need at least one user with a preference_id
-- 4. Run TEST 4 - replace with actual user ID and test the function
-- 5. Run TEST 5 - check if RLS policies are blocking access
