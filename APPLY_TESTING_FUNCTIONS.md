# Apply Testing Functions to Supabase

## Issue
The daily reading testing features (simulate day change, reset to day 1) are failing because the required RPC functions are missing from your Supabase database.

## Quick Fix

1. **Go to your Supabase Dashboard**
   - Navigate to your project
   - Go to SQL Editor

2. **Apply the Testing Functions**
   - Copy the content from `sql/testing_functions.sql`
   - Paste it into the SQL Editor
   - Click "Run"

3. **Verify Functions are Applied**
   Run this query to check if the functions exist:
   ```sql
   SELECT routine_name, routine_type 
   FROM information_schema.routines 
   WHERE routine_schema = 'public' 
   AND routine_name IN ('simulate_day_change', 'reset_to_day_1', 'get_reading_info');
   ```

## Alternative: Use the Full RPC Functions File

If you prefer to apply all functions at once:
1. Use `sql/rpc_functions_only.sql` instead
2. This includes all RPC functions plus sample data

## Testing After Application

Once applied, the testing widget in the daily reading detail screen should work:
- "Next Day" button should advance the reading day
- "Reset to Day 1" button should reset progress
- Reading info should display current/max day

## Functions Applied

- `simulate_day_change(p_user_id, p_days_to_advance)` - Advance reading days for testing
- `reset_to_day_1(p_user_id)` - Reset user progress to day 1
- `get_reading_info(p_user_id)` - Get current day and reading statistics
