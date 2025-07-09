-- ============================================================================
-- TEST SCRIPT FOR DAILY READING FIXES
-- This script tests all the fixed functions to ensure they work correctly
-- ============================================================================

SELECT 'DAILY READING SYSTEM - COMPREHENSIVE TEST' as title;
SELECT '================================================' as separator;

-- Test 1: Check available users and their preferences
SELECT 'TEST 1: Users and Preferences' as test_name;
SELECT 
    u.id as user_id,
    u.email,
    u.preference_id,
    p.name as preference_name
FROM users u
LEFT JOIN preferences p ON u.preference_id = p.id
WHERE u.preference_id IS NOT NULL
LIMIT 5;

-- Test 2: Check available readings for a specific scope
SELECT '';
SELECT 'TEST 2: Available Readings by Scope' as test_name;
SELECT 
    s.name as scope_name,
    s.preference_id,
    COUNT(r.id) as total_readings
FROM scopes s
LEFT JOIN readings r ON r.scope_id = s.id AND r.is_active = true
GROUP BY s.id, s.name, s.preference_id
ORDER BY total_readings DESC;

-- Test 3: Test get_next_uninteracted_reading function
SELECT '';
SELECT 'TEST 3: Testing get_next_uninteracted_reading' as test_name;

-- Get a user with preferences
DO $$
DECLARE
    test_user_id UUID;
    test_preference_id UUID;
    result RECORD;
BEGIN
    -- Get first user with preference
    SELECT u.id, u.preference_id INTO test_user_id, test_preference_id
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing with user_id: %, preference_id: %', test_user_id, test_preference_id;
        
        -- Test the function
        FOR result IN 
            SELECT * FROM get_next_uninteracted_reading(test_user_id, test_preference_id)
        LOOP
            RAISE NOTICE 'Uninteracted reading found: % - %', result.reading_title, result.scope_name;
        END LOOP;
        
        IF NOT FOUND THEN
            RAISE NOTICE 'No uninteracted readings found for this user';
        END IF;
    ELSE
        RAISE NOTICE 'No users with preferences found';
    END IF;
END $$;

-- Test 4: Test get_oldest_reading_for_preference function
SELECT '';
SELECT 'TEST 4: Testing get_oldest_reading_for_preference' as test_name;

DO $$
DECLARE
    test_user_id UUID;
    test_preference_id UUID;
    result RECORD;
BEGIN
    -- Get first user with preference
    SELECT u.id, u.preference_id INTO test_user_id, test_preference_id
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing oldest reading for user_id: %, preference_id: %', test_user_id, test_preference_id;
        
        -- Test the function
        SELECT * INTO result FROM get_oldest_reading_for_preference(test_user_id, test_preference_id);
        
        IF result.reading_id IS NOT NULL THEN
            RAISE NOTICE 'Oldest reading found: % - %', result.reading_title, result.scope_name;
        ELSE
            RAISE NOTICE 'No readings found for this preference';
        END IF;
    END IF;
END $$;

-- Test 5: Test get_user_reading_interaction function
SELECT '';
SELECT 'TEST 5: Testing get_user_reading_interaction' as test_name;

DO $$
DECLARE
    test_user_id UUID;
    test_reading_id UUID;
    result RECORD;
BEGIN
    -- Get a user and reading
    SELECT u.id INTO test_user_id FROM users u WHERE u.preference_id IS NOT NULL LIMIT 1;
    SELECT r.id INTO test_reading_id FROM readings r WHERE r.is_active = true LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_reading_id IS NOT NULL THEN
        RAISE NOTICE 'Testing interaction for user_id: %, reading_id: %', test_user_id, test_reading_id;
        
        -- Test the function
        SELECT * INTO result FROM get_user_reading_interaction(test_user_id, test_reading_id);
        
        RAISE NOTICE 'Interaction result - has_daily_reading: %, has_feedback: %, feedback_type: %, is_read: %', 
                     result.has_daily_reading, result.has_feedback, result.feedback_type, result.is_read;
    END IF;
END $$;

-- Test 6: Test force_regenerate_daily_reading function
SELECT '';
SELECT 'TEST 6: Testing force_regenerate_daily_reading' as test_name;

DO $$
DECLARE
    test_user_id UUID;
    result JSON;
BEGIN
    -- Get first user with preference
    SELECT u.id INTO test_user_id
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing force regenerate for user_id: %', test_user_id;
        
        -- Test the function
        SELECT force_regenerate_daily_reading(test_user_id) INTO result;
        
        RAISE NOTICE 'Force regenerate result: %', result::text;
    END IF;
END $$;

-- Test 7: Check daily readings table after tests
SELECT '';
SELECT 'TEST 7: Daily Readings Table Status' as test_name;
SELECT 
    dr.user_id,
    dr.reading_date,
    dr.is_read,
    r.title as reading_title,
    s.name as scope_name,
    dr.created_at
FROM daily_readings dr
JOIN readings r ON dr.reading_id = r.id
JOIN scopes s ON r.scope_id = s.id
WHERE dr.reading_date = CURRENT_DATE
ORDER BY dr.created_at DESC
LIMIT 10;

-- Test 8: Check for any errors in recent operations
SELECT '';
SELECT 'TEST 8: System Health Check' as test_name;

-- Check constraints
SELECT 'Checking table constraints...' as check_type;

-- Verify no duplicate daily readings per user per day
SELECT 
    user_id,
    reading_date,
    COUNT(*) as count
FROM daily_readings 
GROUP BY user_id, reading_date
HAVING COUNT(*) > 1;

-- If no results, then no duplicates exist
SELECT CASE 
    WHEN NOT EXISTS (
        SELECT 1 FROM daily_readings 
        GROUP BY user_id, reading_date 
        HAVING COUNT(*) > 1
    ) 
    THEN '✅ No duplicate daily readings found'
    ELSE '❌ Duplicate daily readings detected'
END as constraint_check;

SELECT '';
SELECT '================================================' as separator;
SELECT 'ALL TESTS COMPLETED' as completion_status;
SELECT 'Check the output above for any issues' as instruction;
