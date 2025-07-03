-- IMMEDIATE DIAGNOSIS SCRIPT
-- Copy and paste this entire script into your Supabase SQL Editor and run it
-- This will tell us exactly what's wrong

-- ============================================================================
-- DIAGNOSIS 1: Check if RPC functions exist
-- ============================================================================
SELECT '=== CHECKING RPC FUNCTIONS ===' as diagnosis_step;

SELECT 
  'get_today_reading' as function_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_today_reading') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

SELECT 
  'complete_reading' as function_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'complete_reading') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

SELECT 
  'get_reading_subjects' as function_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_reading_subjects') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

SELECT 
  'get_user_progress' as function_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_user_progress') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

-- ============================================================================
-- DIAGNOSIS 2: Check if required tables exist
-- ============================================================================
SELECT '=== CHECKING REQUIRED TABLES ===' as diagnosis_step;

SELECT 
  'reading_subjects' as table_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reading_subjects' AND table_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

SELECT 
  'daily_readings' as table_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_readings' AND table_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

SELECT 
  'user_reading_progress' as table_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_reading_progress' AND table_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

SELECT 
  'reading_completions' as table_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reading_completions' AND table_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status;

-- ============================================================================
-- DIAGNOSIS 3: Check if tables have data
-- ============================================================================
SELECT '=== CHECKING TABLE DATA ===' as diagnosis_step;

-- Only check if tables exist first
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
    RAISE NOTICE 'users table: % rows', (SELECT COUNT(*) FROM users);
  ELSE
    RAISE NOTICE 'users table: MISSING';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'preferences' AND table_schema = 'public') THEN
    RAISE NOTICE 'preferences table: % rows', (SELECT COUNT(*) FROM preferences);
  ELSE
    RAISE NOTICE 'preferences table: MISSING';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reading_subjects' AND table_schema = 'public') THEN
    RAISE NOTICE 'reading_subjects table: % rows', (SELECT COUNT(*) FROM reading_subjects);
  ELSE
    RAISE NOTICE 'reading_subjects table: MISSING';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_readings' AND table_schema = 'public') THEN
    RAISE NOTICE 'daily_readings table: % rows', (SELECT COUNT(*) FROM daily_readings);
  ELSE
    RAISE NOTICE 'daily_readings table: MISSING';
  END IF;
END $$;

-- ============================================================================
-- DIAGNOSIS 4: Get sample user ID for testing
-- ============================================================================
SELECT '=== GETTING SAMPLE USER FOR TESTING ===' as diagnosis_step;

-- Only if users table exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public') THEN
    IF (SELECT COUNT(*) FROM users) > 0 THEN
      RAISE NOTICE 'Sample user found - run this query to see details:';
      RAISE NOTICE 'SELECT id, email, preference_id FROM users LIMIT 1;';
    ELSE
      RAISE NOTICE 'users table exists but has no data';
    END IF;
  END IF;
END $$;

-- ============================================================================
-- FINAL RESULT SUMMARY
-- ============================================================================
SELECT '=== DIAGNOSIS COMPLETE ===' as diagnosis_step;
SELECT 'Check the results above to see what is missing' as next_step;
SELECT 'If functions are missing, run sql/rpc_functions_only.sql' as solution_1;
SELECT 'If tables are missing, run sql/daily_reading_schema.sql' as solution_2;
SELECT 'If data is missing, run sql/daily_reading_dummy_data.sql' as solution_3;
