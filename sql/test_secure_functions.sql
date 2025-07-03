-- TEST SCRIPT FOR FIXED RPC FUNCTIONS
-- Run this after applying the updated rpc_functions_only.sql

-- ============================================================================
-- TEST 1: Check that functions exist and are properly configured
-- ============================================================================
SELECT '=== CHECKING FUNCTION EXISTENCE AND SECURITY ===' as test_step;

SELECT 
  routine_name,
  security_type,
  routine_definition LIKE '%public.%' as uses_explicit_schema,
  routine_definition LIKE '%search_path%' as has_search_path_security
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('get_today_reading', 'complete_reading', 'get_reading_subjects', 'get_user_progress')
ORDER BY routine_name;

-- Expected: All functions should have security_type = 'DEFINER', uses_explicit_schema = true, has_search_path_security = true

-- ============================================================================
-- TEST 2: Test the main function with your user ID
-- ============================================================================
SELECT '=== TESTING get_today_reading FUNCTION ===' as test_step;

-- Test with your specific user ID
SELECT * FROM get_today_reading('23a5b62e-8c35-440e-af6e-e033577aa0b4'::uuid);

-- ============================================================================
-- TEST 3: Test other functions
-- ============================================================================
SELECT '=== TESTING get_reading_subjects FUNCTION ===' as test_step;

SELECT * FROM get_reading_subjects('23a5b62e-8c35-440e-af6e-e033577aa0b4'::uuid);

-- ============================================================================
-- TEST 4: Verify data integrity
-- ============================================================================
SELECT '=== CHECKING DATA COUNTS ===' as test_step;

SELECT 'reading_subjects' as table_name, COUNT(*) as row_count FROM reading_subjects
UNION ALL
SELECT 'daily_readings', COUNT(*) FROM daily_readings
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'preferences', COUNT(*) FROM preferences;

-- ============================================================================
-- SECURITY VERIFICATION
-- ============================================================================
SELECT '=== SECURITY VERIFICATION ===' as test_step;

-- This query verifies that our functions use explicit schema references
-- which makes them secure even with search_path = ''
SELECT 
  routine_name,
  CASE 
    WHEN routine_definition LIKE '%public.daily_readings%' 
     AND routine_definition LIKE '%public.reading_subjects%'
     AND routine_definition LIKE '%public.users%'
    THEN '✅ SECURE (uses explicit schema)'
    ELSE '❌ INSECURE (missing schema references)'
  END as security_status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name = 'get_today_reading';

-- ============================================================================
-- FINAL RESULT
-- ============================================================================
SELECT '=== TEST COMPLETE ===' as final_step;
SELECT 'If all tests pass, your RPC functions are secure AND functional!' as result;
SELECT 'The search_path = '''' warning is actually GOOD - it means your functions are secure' as security_note;
