# Daily Reading Feature Setup Guide

## Database Schema Setup

The daily reading feature requires specific database tables and functions to be created in your Supabase database. Follow these steps to set up the schema:

### Step 1: Apply Database Schema

1. Open your [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to your project
3. Go to **Database** → **SQL Editor**
4. Create a new query
5. Copy and paste the contents of `sql/daily_reading_schema.sql`
6. Click **Run** to execute the schema

This will create:

- `reading_subjects` table
- `daily_readings` table
- `user_reading_progress` table
- `reading_completions` table
- Required indexes
- RPC functions: `get_today_reading`, `complete_reading`, `get_reading_subjects`, `get_user_progress`

### Step 2: Insert Sample Data

1. In the same SQL Editor, create another new query
2. Copy and paste the contents of `sql/daily_reading_dummy_data.sql`
3. Click **Run** to execute the data insertion

This will insert:

- Sample preferences
- Sample users
- Reading subjects (Flutter, React, Psychology, etc.)
- Daily reading content (300+ entries)

### Step 3: Verify Setup

After running both SQL files, you can verify the setup by running:

```sql
-- Check if tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('reading_subjects', 'daily_readings', 'user_reading_progress', 'reading_completions');

-- Check if RPC functions exist
SELECT routine_name FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
AND routine_name IN ('get_today_reading', 'complete_reading', 'get_reading_subjects', 'get_user_progress');

-- Check sample data
SELECT COUNT(*) as reading_count FROM daily_readings;
SELECT COUNT(*) as subject_count FROM reading_subjects;
```

### Step 4: Test the Feature

1. Restart your Flutter app
2. Log in with a user account
3. The home page should now display today's reading
4. You can click "Baca Sekarang" to view the full reading

## Troubleshooting

### Error: "Database schema not initialized"

This means the SQL schema hasn't been applied yet. Follow Steps 1-2 above.

### Error: "relation does not exist"

One or more tables are missing. Re-run the schema SQL file.

### Error: "function does not exist"

The RPC functions haven't been created. Re-run the schema SQL file.

### Error: "column reference is ambiguous"

This indicates an issue with the RPC function SQL code where column names conflict with parameter names.

**Solution**: Re-apply the latest `sql/daily_reading_schema.sql` file which includes fixes for ambiguous column references.

### Error: "type 'Null' is not a subtype of type 'String'"

This indicates a data parsing issue. Usually means:

1. The database schema is outdated - re-run the latest `sql/daily_reading_schema.sql`
2. Required fields in the database are null - check your sample data
3. The RPC function signature has changed - re-run the schema

**Solution**: Re-apply both the schema and dummy data SQL files.

### No readings displayed

1. Check if you have the correct user preference_id in the users table
2. Ensure reading_subjects exist for your preference
3. Verify daily_readings exist for the subjects

## Database Structure

### Tables Overview

- **reading_subjects**: Different reading topics (Flutter, Psychology, etc.)
- **daily_readings**: Individual daily reading content
- **user_reading_progress**: Tracks user's progress through readings
- **reading_completions**: Records when users complete readings

### Key Relationships

```
users.preference_id → preferences.id
reading_subjects.preference_id → preferences.id
daily_readings.subject_id → reading_subjects.id
user_reading_progress.user_id → users.id
user_reading_progress.subject_id → reading_subjects.id
reading_completions.user_id → users.id
reading_completions.reading_id → daily_readings.id
```

## Features Enabled

After successful setup, users will have access to:

✅ Daily reading recommendations based on preferences  
✅ Reading progress tracking  
✅ Completion marking with notes  
✅ Reading time tracking  
✅ Streak counting  
✅ Reading history  
✅ Multiple reading subjects  
✅ Reading mode with font size controls
