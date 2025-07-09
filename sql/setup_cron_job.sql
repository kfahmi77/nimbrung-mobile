-- ============================================================================
-- CRON JOB SETUP FOR DAILY READING GENERATION
-- ============================================================================

-- Create or update the cron job for daily reading generation
-- This runs daily at 23:59:59 GMT+7 (Asia/Jakarta) = 16:59:59 UTC

-- First, remove any existing cron job for daily reading generation
SELECT cron.unschedule('daily-reading-generation');

-- Schedule the daily reading generation to run every day at 23:59:59 GMT+7
-- Cron format: second minute hour day month weekday
-- 59 59 16 * * * = 16:59:59 UTC = 23:59:59 GMT+7 (Asia/Jakarta)
SELECT cron.schedule(
    'daily-reading-generation',
    '59 59 16 * * *',
    'SELECT generate_daily_readings_for_all_users();'
);

-- Verify the cron job was created
SELECT 
    jobname,
    schedule,
    command,
    active
FROM cron.job 
WHERE jobname = 'daily-reading-generation';

SELECT 'Cron job for daily reading generation has been set up successfully' as status;
