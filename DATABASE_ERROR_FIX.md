# COMPLETE FIX FOR "structure of query does not match function result type" ERROR

## The Problem

You're encountering this PostgreSQL error: **"structure of query does not match function result type"**

This happens when:

1. SQL function return types don't exactly match the database column types
2. NULL handling is inconsistent
3. Type casting is missing or incorrect

## COMPLETE SOLUTION (Follow All Steps)

### Step 1: Run Diagnostic Script First

**Before applying any fixes, run the diagnostic script to identify the exact issue:**

1. Open your Supabase dashboard → SQL Editor
2. Copy and run the entire content from `sql/diagnostic_script.sql`
3. Review the output to understand what's wrong

### Step 2: Apply the Corrected Functions

**Apply the corrected SQL functions that fix the structure error:**

1. Open your Supabase dashboard → SQL Editor
2. Copy and run the entire content from `sql/fix_function_structure_error.sql`
3. This script:
   - Drops existing problematic functions
   - Creates new functions with exact type matching
   - Uses proper COALESCE and type casting
   - Simplifies the logic to avoid complex type issues

### Step 3: Key Fixes Applied

#### 1. **Exact Type Matching**

- Changed all return types to exactly match database column types
- Used `TEXT` instead of `VARCHAR` for consistency
- Added explicit `::TEXT` casting for all text fields

#### 2. **Proper NULL Handling**

```sql
-- Before (caused errors):
r.title as title,
s.name as scope_name

-- After (safe):
COALESCE(r.title, '')::TEXT as title,
COALESCE(s.name, 'General')::TEXT as scope_name
```

#### 3. **Simplified Function Logic**

- Separated generation and retrieval logic
- Removed complex queries that caused type mismatches
- Made functions more predictable

#### 4. **Robust Flutter Model**

- Enhanced `DailyReading.fromJson()` to handle any type variations
- Added defensive programming for all fields
- Better error handling in data source

### Step 4: Verify the Fix

**Test that the functions work:**

1. In Supabase SQL Editor, run:

```sql
-- Test function structure (should not error)
SELECT * FROM get_daily_reading('00000000-0000-0000-0000-000000000000');

-- Check function signatures
SELECT
    p.proname as function_name,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname = 'get_daily_reading';
```

### Step 5: Test in Flutter App

**After applying the SQL fixes:**

1. Restart your Flutter app
2. Check the debug console for detailed logs
3. The app should now load the daily reading without database errors

## Database Structure Requirements

Your database must have these tables with correct structure:

```sql
-- Essential tables (should already exist):
- users (id UUID, preference_id UUID)
- preferences (id UUID, preferences_name TEXT/VARCHAR)
- scopes (id UUID, name TEXT/VARCHAR, preference_id UUID, weight INTEGER)
- readings (id UUID, title TEXT/VARCHAR, content TEXT, quote TEXT, scope_id UUID, is_active BOOLEAN)
- daily_readings (id UUID, user_id UUID, reading_id UUID, reading_date DATE, is_read BOOLEAN)
- reading_feedbacks (id UUID, user_id UUID, reading_id UUID, feedback_type TEXT/VARCHAR)
```

### Step 4: Test the Functions

After applying the SQL, test each function individually:

```sql
-- Test getting user preferences
SELECT * FROM get_user_preferences('your-user-id-here');

-- Test getting daily reading
SELECT * FROM get_daily_reading('your-user-id-here');

-- Test submitting feedback
SELECT submit_reading_feedback('user-id', 'reading-id', 'up');
```

### Step 5: Common Issues and Solutions

#### Issue: "function does not exist"

- **Solution**: Make sure you ran the entire SQL script from `daily_reading_system_fixed.sql`

#### Issue: "column does not exist"

- **Solution**: Verify your table structure matches the expected schema

#### Issue: "no data returned"

- **Solution**:
  1. Make sure the user has a preference_id set
  2. Ensure there are readings and scopes in the database
  3. Check that scopes have weight > 0

## Troubleshooting Tips

### If You Still Get Errors:

1. **Check Function Signatures:**

   ```sql
   -- In Supabase SQL Editor, run this to see exact function structure:
   \df get_daily_reading
   ```

2. **Verify Data Types:**

   ```sql
   -- Check your actual column types:
   SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'readings' AND table_schema = 'public';
   ```

3. **Test with Minimal Data:**

   - Create a simple test reading
   - Test the function with a real user ID
   - Check the Flutter debug logs for detailed error info

4. **Common Issues:**
   - **RLS Policies**: Make sure your Row Level Security policies allow the function to access data
   - **Missing Data**: Functions need at least one reading in the database
   - **User Preferences**: Make sure test users have valid preference_id values

## Debug Logging in Flutter

The app includes comprehensive debug logging. Check the console for messages like:

```
[DailyReadingRemoteDataSource] Starting getDailyReading for user: xxx
[DailyReadingRemoteDataSource] Raw response data: {...}
[DailyReadingRemoteDataSource] Successfully parsed DailyReading: {...}
```

## Need More Help?

If you continue to have issues:

1. Run the `sql/diagnostic_script.sql` and share the output
2. Share the exact error message from Supabase
3. Check if you have any custom RLS policies that might be interfering
4. Verify you have sample data in the readings table

The key is that PostgreSQL functions must have return types that EXACTLY match what's being returned in the query - this new SQL fixes that precision issue.

## Expected Behavior After Fix

1. **First Time**: App generates a daily reading for the user
2. **Same Day**: App returns the existing reading for today
3. **Next Day**: App generates a new reading based on preferences
4. **Feedback**: User can give thumbs up/down feedback
5. **Mark as Read**: Reading is marked as read when user goes to discussion

## Debugging

The app now has comprehensive logging. Watch for these log messages:

```
[DailyReadingRemoteDataSource] Starting getDailyReading for user: xxx
[DailyReadingRemoteDataSource] Calling get_daily_reading RPC function
[DailyReadingRemoteDataSource] RPC response received: {...}
```

If you still see errors, the logs will show exactly what's happening in each step.
