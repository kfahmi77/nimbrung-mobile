-- ============================================================================
-- TEST SCRIPT FOR FIXED BULK GENERATION FUNCTION
-- This tests the corrected function with proper job names and status values
-- ============================================================================

-- First apply the fix
\i sql/fix_to_char_error.sql

-- Test the fixed function
SELECT 'Testing the corrected bulk generation function...' as test_info;
SELECT generate_daily_readings_for_all_users() as test_result;

-- Check the results in the logs
SELECT 'Recent job logs:' as log_info;
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
