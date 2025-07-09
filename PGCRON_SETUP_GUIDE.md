# PG_CRON Setup Guide for Supabase Self-Hosted

## Quick Start Guide

### Step 1: Apply the Setup Script

1. Copy the contents of `sql/setup_pgcron_daily_reading.sql`
2. Open your Supabase SQL Editor
3. Paste and execute the script
4. This will:
   - Enable pg_cron extension
   - Create logging tables
   - Create bulk generation functions
   - Schedule the cron jobs

### Step 2: Test the Setup

1. Run the test script: `sql/test_pgcron_setup.sql`
2. This will verify:
   - pg_cron is working
   - Jobs are scheduled
   - Functions are working
   - Show current status

### Step 3: Manual Test (Optional)

```sql
-- Test the function manually first
SELECT generate_daily_readings_for_all_users();
```

## Scheduled Jobs

### Daily Reading Generation

- **Schedule**: Every day at 6:00 AM
- **Function**: `generate_daily_readings_for_all_users()`
- **Purpose**: Generate daily readings for all eligible users

### Cleanup Job

- **Schedule**: Every Sunday at 2:00 AM
- **Function**: `cleanup_old_daily_readings()`
- **Purpose**: Remove old data to keep database clean

## Monitoring

### Check Job Status

```sql
-- See scheduled jobs
SELECT * FROM cron.job;

-- See recent executions
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 5;

-- See our custom logs
SELECT * FROM cron_job_logs ORDER BY created_at DESC LIMIT 10;
```

### Health Checks

```sql
-- Check if today's job ran
SELECT * FROM cron_job_logs
WHERE job_name = 'daily_reading_generation'
AND DATE(started_at) = CURRENT_DATE;

-- Check users without readings
SELECT COUNT(*) FROM users u
LEFT JOIN daily_readings dr ON dr.user_id = u.id AND dr.reading_date = CURRENT_DATE
WHERE dr.id IS NULL AND u.created_at < CURRENT_DATE;
```

## Troubleshooting

### Common Issues

1. **pg_cron not found**

   - Run: `CREATE EXTENSION IF NOT EXISTS pg_cron;`
   - Check PostgreSQL config for pg_cron in shared_preload_libraries

2. **Jobs not running**

   - Check time (scheduled at 6 AM)
   - Check PostgreSQL logs
   - Test manually: `SELECT generate_daily_readings_for_all_users();`

3. **Permission errors**

   - Ensure proper schema grants
   - Check user permissions

4. **No readings generated**
   - Check if `readings` table has active data
   - Check if users exist and are eligible
   - Look at error logs in `cron_job_logs`

### Manual Operations

```sql
-- Force run daily generation
SELECT generate_daily_readings_for_all_users();

-- Reschedule jobs if needed
SELECT cron.unschedule('daily-reading-generation');
SELECT cron.schedule('daily-reading-generation', '0 6 * * *', 'SELECT generate_daily_readings_for_all_users();');

-- Clean up old data manually
SELECT cleanup_old_daily_readings();
```

## Expected Behavior

1. **Every day at 6 AM**: System generates daily readings for all users
2. **Logging**: All operations logged to `cron_job_logs` table
3. **Error handling**: Individual user errors don't stop the whole process
4. **Cleanup**: Old data automatically cleaned weekly
5. **Monitoring**: Easy to check status and troubleshoot issues

## Files Created

- `sql/setup_pgcron_daily_reading.sql` - Main setup script
- `sql/test_pgcron_setup.sql` - Testing and monitoring script
- `PGCRON_SETUP_GUIDE.md` - This guide

## Success Indicators

After setup, you should see:

- ✅ Jobs scheduled in `cron.job` table
- ✅ Daily readings generated for users at 6 AM
- ✅ Logs in `cron_job_logs` table
- ✅ No users missing daily readings (except new users)
- ✅ Clean execution without errors

Your daily reading system will now automatically generate personalized readings for all users every morning!
