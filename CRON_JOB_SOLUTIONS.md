# Daily Reading Cron Job Solutions for Self-Hosted Supabase

Since you're using self-hosted Supabase without Edge Functions, here are multiple approaches to implement automated daily reading generation.

## Solution Options

### 1. PostgreSQL pg_cron Extension (Recommended)

### 2. External Script with System Cron

### 3. Flutter/Dart Background Service

### 4. Docker-based Scheduler

---

## Solution 1: PostgreSQL pg_cron Extension (COMPLETE IMPLEMENTATION) ✅

**READY TO USE** - Complete implementation provided below.

This is the most efficient solution as it runs directly in the database.

### Quick Setup Guide

1. **Verify readiness**: Run `sql/verify_pgcron_readiness.sql`
2. **Apply setup**: Run `sql/setup_pgcron_daily_reading.sql`
3. **Test & monitor**: Use `sql/test_pgcron_setup.sql`
4. **Reference guide**: See `PGCRON_SETUP_GUIDE.md`

### What Gets Installed

- **pg_cron extension** (if not already installed)
- **Bulk generation function** for all users
- **Logging system** for monitoring and debugging
- **Cleanup function** for old data maintenance
- **Scheduled jobs**:
  - Daily reading generation at 6:00 AM
  - Weekly cleanup on Sundays at 2:00 AM

### Features

- ✅ **Automatic daily reading generation** for all eligible users
- ✅ **Comprehensive logging** with execution times and error tracking
- ✅ **Error resilience** - individual user errors don't stop the process
- ✅ **Progress tracking** - logs progress every 100 users
- ✅ **Duplicate prevention** - skips users who already have readings
- ✅ **Data cleanup** - automatic removal of old data
- ✅ **Easy monitoring** - built-in health checks and statistics

### Files Provided

1. **`sql/verify_pgcron_readiness.sql`** - Pre-setup verification
2. **`sql/setup_pgcron_daily_reading.sql`** - Complete setup script
3. **`sql/test_pgcron_setup.sql`** - Testing and monitoring
4. **`PGCRON_SETUP_GUIDE.md`** - Deployment guide

### Setup Instructions

#### Step 1: Enable pg_cron Extension

```sql
-- Connect as superuser and enable the extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant usage to your application user
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT USAGE ON SCHEMA cron TO authenticated;
```

#### Step 2: Create Bulk Daily Reading Generation Function

```sql
-- Function to generate daily readings for all active users
CREATE OR REPLACE FUNCTION generate_daily_readings_for_all_users()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    user_record RECORD;
    generated_count INTEGER := 0;
    error_count INTEGER := 0;
    start_time TIMESTAMP := NOW();
BEGIN
    -- Loop through all active users
    FOR user_record IN
        SELECT id, email
        FROM users
        WHERE id IS NOT NULL
    LOOP
        BEGIN
            -- Generate daily reading for each user
            PERFORM generate_daily_reading(user_record.id);
            generated_count := generated_count + 1;

        EXCEPTION
            WHEN OTHERS THEN
                error_count := error_count + 1;
                -- Log error but continue with other users
                INSERT INTO cron_job_logs (job_name, user_id, status, error_message, created_at)
                VALUES ('daily_reading_generation', user_record.id, 'error', SQLERRM, NOW());
        END;
    END LOOP;

    -- Log successful completion
    INSERT INTO cron_job_logs (job_name, status, message, users_processed, errors_count, execution_time, created_at)
    VALUES (
        'daily_reading_generation',
        'completed',
        'Daily readings generated successfully',
        generated_count,
        error_count,
        EXTRACT(EPOCH FROM (NOW() - start_time)),
        NOW()
    );

    RETURN json_build_object(
        'success', true,
        'message', 'Daily readings generated for all users',
        'users_processed', generated_count,
        'errors', error_count,
        'execution_time_seconds', EXTRACT(EPOCH FROM (NOW() - start_time))
    );
END;
$$;
```

#### Step 3: Create Logging Table

```sql
-- Table to track cron job execution
CREATE TABLE IF NOT EXISTS cron_job_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_name VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES users(id),
    status VARCHAR(20) NOT NULL, -- 'success', 'error', 'completed'
    message TEXT,
    error_message TEXT,
    users_processed INTEGER,
    errors_count INTEGER,
    execution_time NUMERIC, -- seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_cron_job_logs_job_name_date ON cron_job_logs(job_name, created_at);
CREATE INDEX IF NOT EXISTS idx_cron_job_logs_status ON cron_job_logs(status);
```

#### Step 4: Schedule the Cron Job

```sql
-- Schedule daily reading generation at 6:00 AM every day
SELECT cron.schedule(
    'daily-reading-generation',  -- job name
    '0 6 * * *',                 -- cron expression (6:00 AM daily)
    'SELECT generate_daily_readings_for_all_users();'  -- SQL command
);

-- Alternative: Schedule at different times for different timezones
-- Early morning (6 AM)
SELECT cron.schedule('daily-reading-6am', '0 6 * * *', 'SELECT generate_daily_readings_for_all_users();');

-- Backup job in case morning fails (8 PM)
SELECT cron.schedule('daily-reading-8pm', '0 20 * * *', 'SELECT generate_daily_readings_for_all_users();');
```

#### Step 5: Monitor and Manage Cron Jobs

```sql
-- View all scheduled jobs
SELECT * FROM cron.job;

-- View job execution history
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- View our custom logs
SELECT * FROM cron_job_logs ORDER BY created_at DESC LIMIT 20;

-- Unschedule a job if needed
SELECT cron.unschedule('daily-reading-generation');
```

---

## Solution 2: External Script with System Cron

If pg_cron is not available, use an external script with system cron.

### Prerequisites

- Node.js or Python installed on server
- Access to system crontab
- Database connection credentials

### Implementation Files

- `scripts/daily_reading_cron.js` (Node.js version)
- `scripts/daily_reading_cron.py` (Python version)
- Crontab configuration

---

## Solution 3: Flutter/Dart Background Service

For development or small-scale deployments.

### Prerequisites

- Dart SDK installed
- Long-running server or VPS

### Implementation

- `scripts/dart_cron_service.dart`
- Systemd service configuration
- Docker deployment option

---

## Solution 4: Docker-based Scheduler

For containerized environments.

### Prerequisites

- Docker and Docker Compose
- Supabase connection from container network

### Implementation

- `docker/cron-scheduler/Dockerfile`
- `docker-compose.scheduler.yml`
- Health checks and logging

---

## Monitoring and Troubleshooting

### Health Check Queries

```sql
-- Check recent cron job executions
SELECT
    job_name,
    status,
    users_processed,
    errors_count,
    execution_time,
    created_at
FROM cron_job_logs
WHERE job_name = 'daily_reading_generation'
ORDER BY created_at DESC
LIMIT 7; -- Last 7 days

-- Check for failed jobs
SELECT * FROM cron_job_logs
WHERE status = 'error'
AND created_at > NOW() - INTERVAL '7 days';

-- Daily reading generation statistics
SELECT
    DATE(created_at) as date,
    COUNT(*) as total_executions,
    SUM(users_processed) as total_users_processed,
    SUM(errors_count) as total_errors,
    AVG(execution_time) as avg_execution_time
FROM cron_job_logs
WHERE job_name = 'daily_reading_generation'
AND created_at > NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Maintenance Tasks

```sql
-- Clean up old logs (keep last 30 days)
DELETE FROM cron_job_logs
WHERE created_at < NOW() - INTERVAL '30 days';

-- Manually trigger daily reading generation
SELECT generate_daily_readings_for_all_users();

-- Check users without daily readings for today
SELECT u.id, u.email, u.created_at
FROM users u
LEFT JOIN daily_readings dr ON dr.user_id = u.id AND dr.reading_date = CURRENT_DATE
WHERE dr.id IS NULL
AND u.created_at < CURRENT_DATE; -- Exclude today's new users
```

## Recommended Setup

1. **Start with pg_cron** if available (most efficient)
2. **Fall back to external script** if pg_cron not available
3. **Use monitoring queries** to ensure proper operation
4. **Set up alerting** for failed jobs
5. **Regular maintenance** to clean up logs

## Next Steps

Choose your preferred solution and I'll provide the complete implementation files and setup instructions.
