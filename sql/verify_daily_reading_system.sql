-- ============================================================================
-- DAILY READING SYSTEM VERIFICATION SCRIPT
-- ============================================================================

-- Check if all functions exist
SELECT 'Checking function existence...' as step;

SELECT 
    'get_user_reading_interaction' as function_name,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_proc 
WHERE proname = 'get_user_reading_interaction'
UNION ALL
SELECT 
    'get_next_uninteracted_reading' as function_name,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_proc 
WHERE proname = 'get_next_uninteracted_reading'
UNION ALL
SELECT 
    'generate_daily_reading_for_user' as function_name,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_proc 
WHERE proname = 'generate_daily_reading_for_user'
UNION ALL
SELECT 
    'get_user_daily_reading' as function_name,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_proc 
WHERE proname = 'get_user_daily_reading'
UNION ALL
SELECT 
    'submit_reading_feedback' as function_name,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_proc 
WHERE proname = 'submit_reading_feedback'
UNION ALL
SELECT 
    'mark_reading_as_read' as function_name,
    CASE WHEN COUNT(*) > 0 THEN 'EXISTS' ELSE 'MISSING' END as status
FROM pg_proc 
WHERE proname = 'mark_reading_as_read';

-- Check database tables and sample data
SELECT 'Checking database structure...' as step;

SELECT 'Users with preferences:' as info, COUNT(*) as count
FROM users 
WHERE preference_id IS NOT NULL;

SELECT 'Active readings:' as info, COUNT(*) as count
FROM readings 
WHERE is_active = true;

SELECT 'Scopes with readings:' as info, COUNT(DISTINCT s.id) as scope_count, COUNT(r.id) as reading_count
FROM scopes s
LEFT JOIN readings r ON r.scope_id = s.id AND r.is_active = true;

SELECT 'Today''s daily readings:' as info, COUNT(*) as count
FROM daily_readings 
WHERE reading_date = CURRENT_DATE;

-- Sample test with first user (if exists)
SELECT 'Testing with sample user...' as step;

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
        RAISE NOTICE 'Testing with user: %', sample_user_id;
        
        -- Test get daily reading
        SELECT get_user_daily_reading(sample_user_id) INTO test_result;
        RAISE NOTICE 'Daily reading result: %', test_result;
        
    ELSE
        RAISE NOTICE 'No users with preferences found for testing';
    END IF;
END
$$;

-- Check recent cron job logs
SELECT 'Recent cron job logs:' as info;
SELECT 
    job_name, 
    status, 
    message, 
    users_processed, 
    errors_count,
    execution_time,
    created_at
FROM cron_job_logs 
WHERE job_name IN ('daily_reading_gen', 'daily_reading_generation')
ORDER BY created_at DESC 
LIMIT 5;
