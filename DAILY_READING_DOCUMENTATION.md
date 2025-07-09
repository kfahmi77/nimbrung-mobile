# Daily Reading Feature - Complete Implementation

## Overview

This is a complete implementation of a daily reading feature for your Flutter + Supabase application. The system intelligently generates personalized daily readings for users based on their preferences and reading history.

## Features

### Core Functionality

- **Smart Reading Selection**: Uses multiple strategies to select readings:
  1. Prioritizes unread/uninteracted content
  2. Shows newest readings when available
  3. Restarts from beginning when cycle complete
- **User Progress Tracking**: Maintains reading history and cycle counts
- **Feedback System**: Users can like/dislike readings
- **Reading Status**: Track read/unread status
- **Automated Generation**: Daily cron job generates readings for all users

### Database Functions Created

#### RPC Functions (Frontend Integration)

- `get_user_daily_reading(user_id)` - Get/generate today's reading for user
- `submit_reading_feedback(user_id, reading_id, feedback_type)` - Submit like/dislike
- `mark_reading_as_read(user_id, reading_id)` - Mark reading as read

#### Helper Functions

- `generate_daily_reading_for_user(user_id)` - Core generation logic
- `generate_daily_readings_for_all_users()` - Bulk generation for cron
- `get_next_uninteracted_reading()` - Find unread content
- `get_newest_reading_for_preference()` - Get latest content
- `get_oldest_reading_for_preference()` - Restart cycle logic

## Deployment Instructions

### 1. Deploy Database Functions

```sql
-- Run this script in your Supabase SQL editor
\i sql/final_daily_reading_deployment.sql
```

### 2. Validate Deployment

```sql
-- Run validation script to ensure everything is working
\i sql/validate_daily_reading_system.sql
```

### 3. Set Up Cron Job (Optional)

```sql
-- Set up daily generation at 23:59:59 GMT+7 (Asia/Jakarta)
\i sql/setup_cron_job.sql
```

**Note**: The cron job is scheduled to run at 23:59:59 GMT+7 (16:59:59 UTC) to ensure daily readings are generated just before midnight local time.

### 4. Update Flutter Code

The following files have been updated to work with the new system:

- `lib/features/daily_reading/data/datasources/daily_reading_remote_data_source.dart`
- `lib/features/daily_reading/data/models/daily_reading_model.dart`

## Flutter Integration

### Service Usage

```dart
// Get daily reading
final service = DailyReadingService();
final reading = await service.getDailyReading();

// Submit feedback
await service.submitFeedback(readingId, 'up'); // or 'down'

// Mark as read
await service.markAsRead(readingId);
```

### Provider Integration

```dart
// Use with Riverpod
final dailyReadingAsync = ref.watch(dailyReadingProvider);
```

## Reading Selection Logic

The system uses a three-tier strategy for selecting daily readings:

1. **Uninteracted Content First**: Selects readings the user has never seen (no daily_reading record and no feedback)

2. **Newest Content**: If all content has been interacted with, shows the newest reading if it's newer than the user's last consumed reading

3. **Cycle Restart**: If no newer content exists, restarts from the oldest reading and increments the cycle count

## Database Schema

### Required Tables

- `users` - User information with preference_id
- `preferences` - Reading preference categories
- `scopes` - Subcategories within preferences
- `readings` - The actual reading content
- `daily_readings` - Daily reading assignments
- `reading_feedbacks` - User feedback (like/dislike)
- `user_reading_progress` - Progress tracking
- `cron_job_logs` - System monitoring

### Key Relationships

- Users have preferences
- Preferences contain multiple scopes
- Scopes contain multiple readings
- Daily readings link users to specific readings
- Progress tracks user's position in reading cycle

## Monitoring

### Check System Status

```sql
-- View recent generation logs
SELECT * FROM cron_job_logs
WHERE job_name = 'daily_reading_generation'
ORDER BY created_at DESC LIMIT 5;

-- Check today's readings
SELECT COUNT(*) FROM daily_readings
WHERE reading_date = CURRENT_DATE;

-- View user progress
SELECT u.email, urp.total_readings_consumed, urp.cycle_count
FROM user_reading_progress urp
JOIN users u ON urp.user_id = u.id
ORDER BY urp.updated_at DESC;
```

### Manual Generation

```sql
-- Generate for specific user
SELECT generate_daily_reading_for_user('user-id-here');

-- Generate for all users
SELECT generate_daily_readings_for_all_users();
```

## Error Handling

The system includes comprehensive error handling:

- Graceful fallbacks when no content is available
- Constraint conflict resolution
- Detailed logging for troubleshooting
- User-friendly error messages

## Testing

### Manual Testing

```sql
-- Test with sample user
\i sql/test_daily_reading_functions.sql
```

### Frontend Testing

1. Ensure user is authenticated
2. User must have a valid preference_id
3. At least one active reading must exist for the user's preference
4. Test all three scenarios: new user, existing progress, cycle restart

## Troubleshooting

### Common Issues

1. **No readings generated**: Check if user has preference_id set
2. **Function not found**: Ensure deployment script ran successfully
3. **Permission denied**: Verify RLS policies allow access
4. **Constraint violations**: Unique indexes prevent duplicates

### Debug Queries

```sql
-- Check user setup
SELECT id, email, preference_id FROM users WHERE id = 'user-id';

-- Check available readings
SELECT COUNT(*) FROM readings r
JOIN scopes s ON r.scope_id = s.id
WHERE s.preference_id = 'preference-id' AND r.is_active = true;

-- Check user progress
SELECT * FROM user_reading_progress
WHERE user_id = 'user-id';
```

## Performance Considerations

- Indexes on daily_readings (user_id, reading_date)
- Indexes on reading_feedbacks (user_id, reading_id)
- Efficient queries with proper JOIN optimization
- Pagination for large datasets (if needed)

## Security

- All functions use SECURITY DEFINER
- RLS policies should be configured for row-level security
- Input validation for all parameters
- Error messages don't expose sensitive information

## Future Enhancements

Possible improvements:

- Weighted selection based on scope preferences
- Machine learning for personalized recommendations
- Reading difficulty progression
- Social features (sharing, discussions)
- Analytics and insights

---

For support or questions about this implementation, refer to the SQL files in the `sql/` directory for detailed function definitions and examples.
