-- ============================================================================
-- FINAL VALIDATION AND TEST SCRIPT
-- Run this after deploying the final_daily_reading_deployment.sql
-- ============================================================================

-- Check if all functions are deployed
SELECT 'Function Deployment Status:' as info;

SELECT 
    function_name,
    CASE WHEN function_exists THEN 'DEPLOYED ✓' ELSE 'MISSING ✗' END as status
FROM (
    SELECT 
        'get_user_daily_reading' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_user_daily_reading') as function_exists
    UNION ALL
    SELECT 
        'submit_reading_feedback' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'submit_reading_feedback') as function_exists
    UNION ALL
    SELECT 
        'mark_reading_as_read' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'mark_reading_as_read') as function_exists
    UNION ALL
    SELECT 
        'generate_daily_reading_for_user' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'generate_daily_reading_for_user') as function_exists
    UNION ALL
    SELECT 
        'generate_daily_readings_for_all_users' as function_name,
        EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'generate_daily_readings_for_all_users') as function_exists
) t;

-- Check database structure
    SELECT 'Database Structure:' as info;

    SELECT 'Users with preferences:' as metric, COUNT(*) as count
    FROM users 
    WHERE preference_id IS NOT NULL
    UNION ALL
    SELECT 'Active readings:' as metric, COUNT(*) as count
    FROM readings 
    WHERE is_active = true
    UNION ALL
    SELECT 'Scopes available:' as metric, COUNT(*) as count
    FROM scopes
    UNION ALL
    SELECT 'Today''s daily readings:' as metric, COUNT(*) as count
    FROM daily_readings 
    WHERE reading_date = CURRENT_DATE;

    -- Check recent logs
    SELECT 'Recent Cron Job Status:' as info;
    SELECT 
        job_name,
        status,
        message,
        users_processed,
        errors_count,
        execution_time,
        created_at
    FROM cron_job_logs 
    WHERE job_name IN ('daily_reading_gen', 'daily_read_err', 'daily_reading_generation', 'daily_reading_generation_user_error')
    ORDER BY created_at DESC 
    LIMIT 5;

-- Manual test with a sample user (if available)
SELECT 'Manual Test Results:' as info;

DO $$
DECLARE
    sample_user_id UUID;
    test_result JSON;
    sample_reading_id UUID;
BEGIN
    -- Get first user with preference
    SELECT id INTO sample_user_id
    FROM users 
    WHERE preference_id IS NOT NULL
    LIMIT 1;
    
    IF sample_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing with user: %', sample_user_id;
        
        -- Test 1: Get daily reading
        SELECT get_user_daily_reading(sample_user_id) INTO test_result;
        RAISE NOTICE 'Get daily reading result: %', (test_result->>'success');
        
        -- If successful, get the reading ID for further tests
        IF (test_result->>'success')::boolean = true THEN
            sample_reading_id := (test_result->'reading'->>'id')::uuid;
            RAISE NOTICE 'Sample reading ID: %', sample_reading_id;
            
            -- Test 2: Submit feedback
            SELECT submit_reading_feedback(sample_user_id, sample_reading_id, 'up') INTO test_result;
            RAISE NOTICE 'Submit feedback result: %', (test_result->>'success');
            
            -- Test 3: Mark as read
            SELECT mark_reading_as_read(sample_user_id, sample_reading_id) INTO test_result;
            RAISE NOTICE 'Mark as read result: %', (test_result->>'success');
        END IF;
        
    ELSE
        RAISE NOTICE 'No users with preferences found for testing';
    END IF;
END
$$;

SELECT 'Daily Reading System Validation Complete!' as final_status;
