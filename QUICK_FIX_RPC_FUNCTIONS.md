# Quick Fix for Missing RPC Functions

Since your database tables already exist but the RPC functions are missing, follow these steps:

## 1. Apply RPC Functions

1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Copy and paste the entire content from `sql/rpc_functions_only.sql`
4. Click **Run** to execute the script

## 2. What This Creates

- `get_today_reading(user_id, target_day)` - Gets daily reading for a user
- `complete_reading(p_user_id, p_reading_id, ...)` - Marks reading as complete
- `get_reading_subjects(user_id)` - Gets available reading subjects
- `get_user_progress(p_user_id, p_subject_id)` - Gets user progress
- Sample reading subjects and daily readings for testing

## 3. Test the Setup

Run this query in SQL Editor to test:

```sql
-- Check if functions exist
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%reading%';

-- Test the main function (replace with your actual user ID)
SELECT * FROM get_today_reading('your-user-id'::uuid);
```

## 4. What to Check if Still Getting Errors

1. **User exists**: Make sure your user ID exists in the `users` table
2. **User has preference**: User must have a `preference_id` set
3. **Reading subjects exist**: There must be reading subjects with that preference
4. **Daily readings exist**: There must be daily reading content

## 5. Troubleshooting

If you get "no data found" errors:

- Check if your user has a preference_id set
- Verify reading subjects exist for that preference
- Ensure daily_readings table has content

The functions are designed to be secure with `SET search_path = ''` to prevent search path attacks.
