-- ============================================================================
-- DAILY READING SYSTEM MANUAL TESTS
-- ============================================================================

-- Apply the TO_CHAR fix first
\i sql/fix_to_char_error.sql

-- Test 1: Check if bulk generation works
SELECT 'TEST 1: Bulk Generation' as test_name;
SELECT generate_daily_readings_for_all_users() as result;

-- Test 2: Get daily reading for specific user (replace with actual user ID)
SELECT 'TEST 2: Get Daily Reading for User' as test_name;

DO $$
DECLARE
    sample_user_id UUID;
    test_result JSON;
BEGIN
    -- Get first user with preference
    SELECT id INTO sample_user_id
    FROM users 
    WHERE preference_id IS NOT NULL
    LIMIT 1;
    
    IF sample_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing get_user_daily_reading with user: %', sample_user_id;
        SELECT get_user_daily_reading(sample_user_id) INTO test_result;
        RAISE NOTICE 'Result: %', test_result;
    ELSE
        RAISE NOTICE 'No users with preferences found for testing';
    END IF;
END
$$;

-- Test 3: Submit feedback (replace with actual user and reading IDs)
SELECT 'TEST 3: Submit Feedback' as test_name;

DO $$
DECLARE
    sample_user_id UUID;
    sample_reading_id UUID;
    test_result JSON;
BEGIN
    -- Get first user with preference
    SELECT id INTO sample_user_id
    FROM users 
    WHERE preference_id IS NOT NULL
    LIMIT 1;
    
    -- Get first active reading
    SELECT r.id INTO sample_reading_id
    FROM readings r
    JOIN scopes s ON r.scope_id = s.id
    WHERE r.is_active = true
    LIMIT 1;
    
    IF sample_user_id IS NOT NULL AND sample_reading_id IS NOT NULL THEN
        RAISE NOTICE 'Testing submit_reading_feedback with user: % and reading: %', sample_user_id, sample_reading_id;
        SELECT submit_reading_feedback(sample_user_id, sample_reading_id, 'up') INTO test_result;
        RAISE NOTICE 'Result: %', test_result;
    ELSE
        RAISE NOTICE 'Cannot test feedback - missing user or reading data';
    END IF;
END
$$;

-- Test 4: Mark as read (replace with actual user and reading IDs)
SELECT 'TEST 4: Mark as Read' as test_name;

DO $$
DECLARE
    sample_user_id UUID;
    sample_reading_id UUID;
    test_result JSON;
BEGIN
    -- Get user and reading from today's daily readings
    SELECT dr.user_id, dr.reading_id INTO sample_user_id, sample_reading_id
    FROM daily_readings dr
    WHERE dr.reading_date = CURRENT_DATE
    LIMIT 1;
    
    IF sample_user_id IS NOT NULL AND sample_reading_id IS NOT NULL THEN
        RAISE NOTICE 'Testing mark_reading_as_read with user: % and reading: %', sample_user_id, sample_reading_id;
        SELECT mark_reading_as_read(sample_user_id, sample_reading_id) INTO test_result;
        RAISE NOTICE 'Result: %', test_result;
    ELSE
        RAISE NOTICE 'Cannot test mark as read - no daily readings found for today';
    END IF;
END
$$;

-- Helper: Get sample user and reading IDs for testing
SELECT 'HELPER: Sample Data for Testing' as info;

SELECT 
    'Sample User ID:' as label,
    id as value
FROM users 
WHERE preference_id IS NOT NULL
LIMIT 1;

SELECT 
    'Sample Reading ID:' as label,
    r.id as value
FROM readings r
JOIN scopes s ON r.scope_id = s.id
WHERE r.is_active = true
LIMIT 1;

-- Check user reading progress
SELECT 'Current User Progress:' as info;
SELECT 
    u.email,
    p.preferences_name,
    urp.last_reading_created_at,
    urp.total_readings_consumed,
    urp.cycle_count
FROM user_reading_progress urp
JOIN users u ON urp.user_id = u.id
JOIN preferences p ON urp.preference_id = p.id
ORDER BY urp.updated_at DESC
LIMIT 10;

-- Check recent cron job logs with correct job name
SELECT 'Recent Cron Job Logs:' as info;
SELECT 
    job_name,
    status,
    message,
    users_processed,
    errors_count,
    execution_time,
    created_at
FROM cron_job_logs 
WHERE job_name IN ('daily_reading_gen', 'daily_read_err')
ORDER BY created_at DESC 
LIMIT 5;
