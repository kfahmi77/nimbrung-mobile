# Daily Reading Database Setup Guide

## Prerequisites

- Active Supabase project
- Access to Supabase SQL Editor or Database Dashboard

## Step-by-Step Setup Instructions

### 1. Access Supabase SQL Editor

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** from the sidebar
3. Create a new query

### 2. Apply Database Schema

Copy and paste the entire content from `sql/daily_reading_schema.sql` into the SQL Editor and run it.

This will create:

- `reading_subjects` table
- `daily_readings` table
- `user_reading_progress` table
- `reading_completions` table
- Required indexes for performance
- 4 RPC functions with proper security settings:
  - `get_today_reading(user_id, target_day)`
  - `complete_reading(p_user_id, p_reading_id, p_read_time_seconds, p_was_helpful, p_user_note)`
  - `get_reading_subjects(user_id)`
  - `get_user_progress(p_user_id, p_subject_id)`

### 3. Insert Dummy Data

Copy and paste the entire content from `sql/daily_reading_dummy_data.sql` into the SQL Editor and run it.

This will insert:

- Sample preferences
- Sample users
- Reading subjects for different categories
- Daily reading content for multiple days

### 4. Verify Installation

Run this query to verify the setup:

```sql
-- Check if tables exist and have data
SELECT 'reading_subjects' as table_name, COUNT(*) as row_count FROM reading_subjects
UNION ALL
SELECT 'daily_readings', COUNT(*) FROM daily_readings
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'preferences', COUNT(*) FROM preferences;

-- Test the RPC function
SELECT * FROM get_today_reading('user-prog-001'::uuid);
```

### 5. Common Issues and Solutions

#### Issue: "relation does not exist"

**Solution**: Make sure you've applied the schema first before the dummy data.

#### Issue: "function does not exist"

**Solution**: Verify all RPC functions were created by checking the Functions section in Supabase dashboard.

#### Issue: "foreign key violation"

**Solution**: Ensure preferences and users are inserted before reading subjects and daily readings.

### 6. Security Notes

All RPC functions are created with:

- `SECURITY DEFINER` for proper permissions
- `SET search_path = ''` to prevent search path attacks
- Proper parameter validation

### 7. Test Your Setup

After applying both files, test the app:

1. Run the Flutter app
2. Navigate to the home page
3. You should see the daily reading card
4. Try completing a reading to test the full flow

## Troubleshooting

If you encounter any issues:

1. Check the Supabase logs for detailed error messages
2. Verify your user has proper RLS policies set
3. Ensure your Flutter app's user ID exists in the users table
4. Check that the user has a preference_id set

## File Locations

- Schema: `sql/daily_reading_schema.sql`
- Dummy Data: `sql/daily_reading_dummy_data.sql`
