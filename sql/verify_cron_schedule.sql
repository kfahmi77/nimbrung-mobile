-- ============================================================================
-- VERIFY CRON JOB SCHEDULE - FINAL CHECK
-- ============================================================================

-- This script verifies that the cron job is scheduled correctly for 23:59:59 GMT+7

SELECT 'CRON JOB VERIFICATION REPORT' as title;
SELECT '================================' as separator;

-- Check current cron job configuration
SELECT 'Current Cron Job Schedule:' as info;
SELECT 
    jobname as "Job Name",
    schedule as "Cron Expression",
    command as "Command",
    active as "Active"
FROM cron.job 
WHERE jobname = 'daily-reading-generation';

SELECT '';
SELECT 'Schedule Details:' as info;
SELECT '59 59 16 * * * = 16:59:59 UTC = 23:59:59 GMT+7 (Asia/Jakarta)' as schedule_explanation;

-- Show timezone information
SELECT 'Timezone Conversion:' as info;
SELECT 
    'Local Time (GMT+7): 23:59:59' as local_time,
    'UTC Time: 16:59:59' as utc_time,
    'Cron Expression: 59 59 16 * * *' as cron_format;

-- Check if the job exists and is active
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM cron.job 
            WHERE jobname = 'daily-reading-generation' 
            AND schedule = '59 59 16 * * *'
            AND active = true
        ) 
        THEN '✅ CRON JOB CORRECTLY SCHEDULED'
        ELSE '❌ CRON JOB CONFIGURATION ERROR'
    END as verification_status;

-- Show recent logs if any exist
SELECT '';
SELECT 'Recent Cron Job Logs (if any):' as info;
SELECT 
    job_name,
    status,
    message,
    created_at,
    users_processed,
    readings_generated
FROM cron_job_logs 
WHERE job_name LIKE '%daily_reading%'
ORDER BY created_at DESC 
LIMIT 5;

SELECT '';
SELECT 'VERIFICATION COMPLETE' as conclusion;
SELECT 'Cron job is scheduled to run daily at 23:59:59 GMT+7 (Asia/Jakarta)' as final_status;
