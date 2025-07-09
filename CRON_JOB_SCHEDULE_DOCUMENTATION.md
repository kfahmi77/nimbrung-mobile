# Cron Job Scheduling Documentation

## Daily Reading Generation Schedule

### Current Schedule
- **Local Time (GMT+7)**: 23:59:59 (Asia/Jakarta)
- **UTC Time**: 16:59:59
- **Cron Expression**: `59 59 16 * * *`

### Timezone Considerations

The cron job is scheduled to run at **23:59:59 GMT+7** (Asia/Jakarta timezone), which corresponds to **16:59:59 UTC**.

This timing ensures that:
1. Daily readings are generated just before midnight local time
2. Users get fresh content for the next day
3. The system processes all users before the day officially ends

### Cron Expression Format

```
59 59 16 * * *
│  │  │  │ │ │
│  │  │  │ │ └── Day of week (0-7, where 0 and 7 are Sunday)
│  │  │  │ └──── Month (1-12)
│  │  │  └────── Day of month (1-31)
│  │  └──────── Hour (0-23) [UTC]
│  └────────── Minute (0-59)
│─────────── Second (0-59)
```

### Implementation

The cron job calls the PostgreSQL function:
```sql
SELECT generate_daily_readings_for_all_users();
```

This function:
- Generates daily readings for all active users
- Logs all operations in the `cron_job_logs` table
- Handles errors gracefully
- Provides comprehensive status reporting

### Deployment Command

To set up or update the cron job:
```sql
\i sql/setup_cron_job.sql
```

### Verification

After deployment, verify the cron job is scheduled correctly:
```sql
SELECT 
    jobname,
    schedule,
    command,
    active
FROM cron.job 
WHERE jobname = 'daily-reading-generation';
```

Expected output:
```
jobname                  | schedule      | command                                    | active
-------------------------|---------------|--------------------------------------------|---------
daily-reading-generation | 59 59 16 * * * | SELECT generate_daily_readings_for_all_users(); | t
```

### Monitoring

Monitor cron job execution through the logs:
```sql
SELECT 
    job_name,
    status,
    message,
    error_message,
    users_processed,
    readings_generated,
    created_at
FROM cron_job_logs 
WHERE job_name = 'daily_reading_bulk_generation'
ORDER BY created_at DESC 
LIMIT 10;
```

### Timezone Conversion Reference

| Local Time (GMT+7) | UTC Time | Cron Expression |
|-------------------|----------|-----------------|
| 00:00:00 | 17:00:00 | `0 0 17 * * *` |
| 06:00:00 | 23:00:00 | `0 0 23 * * *` |
| 12:00:00 | 05:00:00 | `0 0 5 * * *` |
| 18:00:00 | 11:00:00 | `0 0 11 * * *` |
| **23:59:59** | **16:59:59** | **`59 59 16 * * *`** |

### Notes

1. **Daylight Saving Time**: Indonesia (GMT+7) does not observe daylight saving time, so the UTC offset remains constant.

2. **Execution Window**: The job runs at 23:59:59 to ensure readings are available for the next day by midnight.

3. **Error Handling**: If the job fails, it logs detailed error information and continues processing other users.

4. **Performance**: The bulk generation function is optimized to handle all users efficiently in a single execution.

5. **Backup Schedule**: Consider setting up a backup job 1 hour earlier (22:59:59) if the main job fails.

---

*Last Updated: July 2025*
*Status: Scheduled for 23:59:59 GMT+7 (16:59:59 UTC)*
