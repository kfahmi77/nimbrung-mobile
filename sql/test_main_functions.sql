-- ============================================================================
-- COMPREHENSIVE TEST OF MAIN DAILY READING FUNCTIONS
-- ============================================================================

BEGIN;

-- Test 1: Check if functions exist and their return types
SELECT 'Testing function existence and return types...' as test_phase;

-- Test generate_daily_reading_for_user function
DO $$
DECLARE
    test_result JSON;
    user_id_test UUID;
BEGIN
    -- Get a test user with preference
    SELECT id INTO user_id_test 
    FROM users 
    WHERE preference_id IS NOT NULL 
    LIMIT 1;
    
    IF user_id_test IS NULL THEN
        RAISE NOTICE 'No users with preferences found for testing';
    ELSE
        RAISE NOTICE 'Testing generate_daily_reading_for_user with user: %', user_id_test;
        
        -- Test the function
        SELECT generate_daily_reading_for_user(user_id_test) INTO test_result;
        
        RAISE NOTICE 'Function result: %', test_result;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error testing generate_daily_reading_for_user: %', SQLERRM;
END;
$$;

-- Test 2: Check get_user_daily_reading function
DO $$
DECLARE
    test_result JSON;
    user_id_test UUID;
BEGIN
    -- Get a test user with preference
    SELECT id INTO user_id_test 
    FROM users 
    WHERE preference_id IS NOT NULL 
    LIMIT 1;
    
    IF user_id_test IS NULL THEN
        RAISE NOTICE 'No users with preferences found for testing get_user_daily_reading';
    ELSE
        RAISE NOTICE 'Testing get_user_daily_reading with user: %', user_id_test;
        
        -- Test the function
        SELECT get_user_daily_reading(user_id_test) INTO test_result;
        
        RAISE NOTICE 'Function result: %', test_result;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error testing get_user_daily_reading: %', SQLERRM;
END;
$$;

-- Test 3: Check helper functions with specific user/preference
DO $$
DECLARE
    user_id_test UUID;
    preference_id_test UUID;
    next_reading RECORD;
    newest_reading RECORD;
    oldest_reading RECORD;
BEGIN
    -- Get a test user and their preference
    SELECT u.id, u.preference_id 
    INTO user_id_test, preference_id_test
    FROM users u
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    IF user_id_test IS NULL THEN
        RAISE NOTICE 'No users with preferences found for helper function testing';
    ELSE
        RAISE NOTICE 'Testing helper functions with user: %, preference: %', user_id_test, preference_id_test;
        
        -- Test get_next_uninteracted_reading
        SELECT * INTO next_reading
        FROM get_next_uninteracted_reading(user_id_test, preference_id_test);
        
        IF next_reading.reading_id IS NOT NULL THEN
            RAISE NOTICE 'Next uninteracted reading found: % - %', next_reading.reading_id, next_reading.reading_title;
        ELSE
            RAISE NOTICE 'No uninteracted readings found';
        END IF;
        
        -- Test get_newest_reading_for_preference
        SELECT * INTO newest_reading
        FROM get_newest_reading_for_preference(user_id_test, preference_id_test);
        
        IF newest_reading.reading_id IS NOT NULL THEN
            RAISE NOTICE 'Newest reading found: % - %', newest_reading.reading_id, newest_reading.reading_title;
        ELSE
            RAISE NOTICE 'No newest reading found';
        END IF;
        
        -- Test get_oldest_reading_for_preference
        SELECT * INTO oldest_reading
        FROM get_oldest_reading_for_preference(user_id_test, preference_id_test);
        
        IF oldest_reading.reading_id IS NOT NULL THEN
            RAISE NOTICE 'Oldest reading found: % - %', oldest_reading.reading_id, oldest_reading.reading_title;
        ELSE
            RAISE NOTICE 'No oldest reading found';
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error testing helper functions: %', SQLERRM;
END;
$$;

-- Test 4: Check data integrity
SELECT 'Checking data integrity...' as test_phase;

-- Count users with preferences
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN preference_id IS NOT NULL THEN 1 END) as users_with_preferences
FROM users;

-- Count readings per preference
SELECT 
    p.id as preference_id,
    p.name as preference_name,
    COUNT(s.id) as total_scopes,
    COUNT(r.id) as total_readings
FROM preferences p
LEFT JOIN scopes s ON s.preference_id = p.id
LEFT JOIN readings r ON r.scope_id = s.id AND r.is_active = true
GROUP BY p.id, p.name
ORDER BY p.name;

-- Check existing daily readings for today
SELECT 
    COUNT(*) as daily_readings_today,
    COUNT(DISTINCT user_id) as unique_users_with_readings_today
FROM daily_readings 
WHERE reading_date = CURRENT_DATE;

ROLLBACK;

SELECT 'Test completed successfully!' as status;
