-- ============================================================================
-- QUICK TEST FOR FIXED BULK GENERATION FUNCTION
-- This tests the fix for both TO_CHAR and varchar length errors
-- ============================================================================

-- Test the function with shortened job names
SELECT 'Testing bulk generation with fixed job names...' as test_step;
SELECT generate_daily_readings_for_all_users() as result;

-- Check if logs were created successfully
SELECT 'Checking if logs were created successfully...' as verification_step;
SELECT 
    job_name,
    status,
    message,
    created_at
FROM cron_job_logs 
WHERE job_name = 'daily_reading_gen'
ORDER BY created_at DESC 
LIMIT 3;
