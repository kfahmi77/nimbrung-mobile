-- DIAGNOSTIC SCRIPT FOR DAILY READING SYSTEM
-- Run this script to identify the exact cause of the "structure of query does not match function result type" error

-- ============================================================================
-- STEP 1: Check if tables exist and have correct structure
-- ============================================================================

-- Check if required tables exist
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'preferences', 'scopes', 'readings', 'daily_readings', 'reading_feedbacks')
ORDER BY table_name, ordinal_position;

-- ============================================================================
-- STEP 2: Check current function definitions
-- ============================================================================

-- Check if functions exist and their signatures
SELECT 
    p.proname as function_name,
    pg_get_function_result(p.oid) as return_type,
    pg_get_function_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname IN ('get_daily_reading', 'generate_daily_reading', 'submit_reading_feedback', 'mark_reading_as_read');

-- ============================================================================
-- STEP 3: Test data existence
-- ============================================================================

-- Check if we have sample data
SELECT 'users' as table_name, count(*) as row_count FROM users
UNION ALL
SELECT 'preferences', count(*) FROM preferences
UNION ALL
SELECT 'scopes', count(*) FROM scopes
UNION ALL
SELECT 'readings', count(*) FROM readings
UNION ALL
SELECT 'daily_readings', count(*) FROM daily_readings
UNION ALL
SELECT 'reading_feedbacks', count(*) FROM reading_feedbacks;

-- ============================================================================
-- STEP 4: Check column data types that might cause issues
-- ============================================================================

-- Check specific columns that are used in functions
SELECT 
    table_name,
    column_name,
    data_type,
    character_maximum_length,
    numeric_precision
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND (
    (table_name = 'readings' AND column_name IN ('title', 'content', 'quote'))
    OR (table_name = 'scopes' AND column_name = 'name')
    OR (table_name = 'daily_readings' AND column_name IN ('reading_date', 'is_read'))
    OR (table_name = 'reading_feedbacks' AND column_name = 'feedback_type')
    OR (table_name = 'preferences' AND column_name = 'preferences_name')
);

-- ============================================================================
-- STEP 5: Simple test of problematic function (will show exact error)
-- ============================================================================

-- Test the get_daily_reading function with a dummy UUID
-- This will show the exact error message
DO $$
DECLARE
    test_user_id UUID := '00000000-0000-0000-0000-000000000000';
    test_result RECORD;
BEGIN
    BEGIN
        -- Try to call the function
        SELECT * INTO test_result FROM get_daily_reading(test_user_id) LIMIT 1;
        RAISE NOTICE 'Function call succeeded - no structure error';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error calling get_daily_reading: %', SQLERRM;
    END;
END $$;

-- ============================================================================
-- STEP 6: Check RLS policies (might cause access issues)
-- ============================================================================

-- Check if RLS is enabled and what policies exist
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'preferences', 'scopes', 'readings', 'daily_readings', 'reading_feedbacks');

-- Show RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'public';

-- ============================================================================
-- FINAL RECOMMENDATION
-- ============================================================================

SELECT 'Run this diagnostic script and check the output. Look for:
1. Missing tables or columns
2. Data type mismatches in function returns
3. Error messages in the function test
4. RLS policies that might block access

Then apply the fix_function_structure_error.sql script.' as recommendation;
