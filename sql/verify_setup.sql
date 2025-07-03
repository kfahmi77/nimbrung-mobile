-- VERIFICATION SCRIPT - Run this in Supabase SQL Editor to diagnose issues
-- This will help identify what's wrong with the RPC functions setup

-- ============================================================================
-- STEP 1: Check if functions exist
-- ============================================================================
SELECT 
  routine_name,
  routine_type,
  data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('get_today_reading', 'complete_reading', 'get_reading_subjects', 'get_user_progress')
ORDER BY routine_name;

-- ============================================================================
-- STEP 2: Check if required tables exist and have data
-- ============================================================================
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name AND table_schema = 'public') as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN ('reading_subjects', 'daily_readings', 'user_reading_progress', 'reading_completions', 'users', 'preferences')
ORDER BY table_name;

-- ============================================================================
-- STEP 3: Check data in key tables
-- ============================================================================
SELECT 'preferences' as table_name, COUNT(*) as row_count FROM preferences
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL  
SELECT 'reading_subjects', COUNT(*) FROM reading_subjects
UNION ALL
SELECT 'daily_readings', COUNT(*) FROM daily_readings;

-- ============================================================================
-- STEP 4: Test get_today_reading function (you'll need to replace the UUID)
-- ============================================================================
-- First, get a sample user ID
SELECT 'Sample User IDs:' as info, id, email, preference_id FROM users LIMIT 3;

-- Then test the function with a real user ID (replace with actual ID from above)
-- SELECT * FROM get_today_reading('replace-with-actual-user-id'::uuid);

-- ============================================================================
-- STEP 5: Check function permissions and search_path
-- ============================================================================
SELECT 
  routine_name,
  security_type,
  sql_data_access,
  routine_definition LIKE '%search_path%' as has_search_path_set
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('get_today_reading', 'complete_reading', 'get_reading_subjects', 'get_user_progress');

-- ============================================================================
-- EXPECTED RESULTS:
-- ============================================================================
-- Step 1: Should show 4 functions (get_today_reading, complete_reading, get_reading_subjects, get_user_progress)
-- Step 2: Should show 6 tables with appropriate column counts
-- Step 3: Should show non-zero counts for at least preferences, users, and reading_subjects
-- Step 4: Should return at least one user ID to test with
-- Step 5: All functions should have security_type = 'DEFINER' and has_search_path_set = true
