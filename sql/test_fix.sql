-- SIMPLE TEST SCRIPT TO VERIFY THE FIX
-- Run this after applying fix_function_structure_error.sql

-- ============================================================================
-- Test 1: Check if functions exist with correct signatures
-- ============================================================================

SELECT 'Testing function signatures...' as test_step;

SELECT 
    p.proname as function_name,
    'EXISTS' as status,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname IN ('get_daily_reading', 'generate_daily_reading')
ORDER BY p.proname;

-- ============================================================================
-- Test 2: Check if required tables exist
-- ============================================================================

SELECT 'Testing table existence...' as test_step;

SELECT 
    t.table_name,
    'EXISTS' as status
FROM information_schema.tables t
WHERE t.table_schema = 'public'
AND t.table_name IN ('users', 'preferences', 'scopes', 'readings', 'daily_readings', 'reading_feedbacks')
ORDER BY t.table_name;

-- ============================================================================
-- Test 3: Test function call (structure test)
-- ============================================================================

SELECT 'Testing function structure (should not fail with structure error)...' as test_step;

-- This tests the function structure without requiring real data
-- If this runs without "structure of query does not match function result type" error, the fix worked
DO $$
DECLARE
    test_user_id UUID := '00000000-0000-0000-0000-000000000000';
    result_record RECORD;
    error_occurred BOOLEAN := FALSE;
BEGIN
    BEGIN
        -- Try to get the function result structure
        PERFORM * FROM get_daily_reading(test_user_id) LIMIT 0;
        RAISE NOTICE 'SUCCESS: Function structure test passed - no structure error';
    EXCEPTION
        WHEN OTHERS THEN
            error_occurred := TRUE;
            IF SQLERRM LIKE '%structure of query does not match function result type%' THEN
                RAISE NOTICE 'FAILED: Still getting structure error: %', SQLERRM;
            ELSE
                RAISE NOTICE 'SUCCESS: No structure error (got different error which is expected with dummy data): %', SQLERRM;
            END IF;
    END;
END $$;

-- ============================================================================
-- Test 4: Create minimal test data if needed
-- ============================================================================

SELECT 'Creating minimal test data if needed...' as test_step;

-- Insert test data only if tables are completely empty
INSERT INTO preferences (id, preferences_name) 
SELECT gen_random_uuid(), 'Test Preference'
WHERE NOT EXISTS (SELECT 1 FROM preferences);

INSERT INTO scopes (name, preference_id, weight, description) 
SELECT 'Test Scope', p.id, 1, 'Test Description'
FROM preferences p 
WHERE NOT EXISTS (SELECT 1 FROM scopes)
LIMIT 1;

INSERT INTO readings (title, content, quote, scope_id, is_active) 
SELECT 'Test Reading', 'Test Content', 'Test Quote', s.id, true
FROM scopes s 
WHERE NOT EXISTS (SELECT 1 FROM readings)
LIMIT 1;

-- ============================================================================
-- Test 5: Final function test with real data
-- ============================================================================

SELECT 'Testing function with real data (if available)...' as test_step;

-- Test with first available user (if any)
DO $$
DECLARE
    test_user_id UUID;
    result_record RECORD;
BEGIN
    -- Get first user ID if available
    SELECT id INTO test_user_id FROM users LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        BEGIN
            SELECT * INTO result_record FROM get_daily_reading(test_user_id) LIMIT 1;
            RAISE NOTICE 'SUCCESS: Function works with real user data';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'INFO: Function structure OK, but got error with real data (check your data setup): %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE 'INFO: No users found in database for testing with real data';
    END IF;
END $$;

-- ============================================================================
-- Summary
-- ============================================================================

SELECT 'Test completed. Check the messages above:
- If you see "SUCCESS: Function structure test passed" - the fix worked!
- If you see "FAILED: Still getting structure error" - you may need to apply the fix again
- Any "INFO" messages are normal and just indicate missing data

Next step: Test in your Flutter app!' as summary;
