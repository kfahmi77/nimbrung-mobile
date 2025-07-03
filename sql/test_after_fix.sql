-- VERIFICATION SCRIPT - Run after applying the fixed RPC functions
-- This will verify everything is working properly

-- ============================================================================
-- TEST 1: Verify all tables exist
-- ============================================================================
SELECT '=== CHECKING TABLES ===' as test_step;

SELECT 
  table_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t.table_name AND table_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status
FROM (VALUES 
  ('reading_subjects'),
  ('daily_readings'), 
  ('user_reading_progress'),
  ('reading_completions'),
  ('users'),
  ('preferences')
) AS t(table_name);

-- ============================================================================
-- TEST 2: Verify RPC functions exist
-- ============================================================================
SELECT '=== CHECKING RPC FUNCTIONS ===' as test_step;

SELECT 
  routine_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = r.routine_name AND routine_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status
FROM (VALUES 
  ('get_today_reading'),
  ('complete_reading'),
  ('get_reading_subjects'),
  ('get_user_progress')
) AS r(routine_name);

-- ============================================================================
-- TEST 3: Verify data exists
-- ============================================================================
SELECT '=== CHECKING DATA ===' as test_step;

SELECT 'reading_subjects' as table_name, COUNT(*) as row_count FROM reading_subjects
UNION ALL
SELECT 'daily_readings', COUNT(*) FROM daily_readings
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL  
SELECT 'preferences', COUNT(*) FROM preferences;

-- ============================================================================
-- TEST 4: Test the RPC function
-- ============================================================================
SELECT '=== TESTING RPC FUNCTION ===' as test_step;

-- Test with your user ID
SELECT * FROM get_today_reading('23a5b62e-8c35-440e-af6e-e033577aa0b4'::uuid);

-- ============================================================================
-- EXPECTED RESULTS:
-- ============================================================================
-- Test 1: All tables should show ✅ EXISTS
-- Test 2: All RPC functions should show ✅ EXISTS  
-- Test 3: reading_subjects should have 2+ rows, daily_readings should have 3+ rows
-- Test 4: Should return a reading with title, content, etc.

SELECT '=== VERIFICATION COMPLETE ===' as final_step;
SELECT 'If all tests pass, the daily reading feature should now work in your Flutter app!' as result;
