# Daily Reading Feature - Complete Troubleshooting Guide

## Your Current Issue
Even after applying the RPC functions, you're still getting the error:
```
Failed to get today reading: Exception: RPC functions missing
```

## Root Cause Analysis

The issue is likely one of these:

1. **RPC Functions didn't get created properly**
2. **User doesn't exist in the `users` table** (exists in Auth but not in your custom users table)
3. **User exists but has no `preference_id`**
4. **No reading subjects exist for the user's preference**
5. **RLS (Row Level Security) policies are blocking access**

## Complete Solution Steps

### Step 1: Apply Complete Fix
Run `sql/complete_fix.sql` in your Supabase SQL Editor. This will:
- Re-create all RPC functions with proper security
- Ensure essential data exists (preferences, reading subjects, daily readings)
- Fix users without preferences
- Provide test queries

### Step 2: Debug the Exact Issue
Run `sql/debug_step_by_step.sql` to identify the specific problem:

1. **Check if functions exist** - Run TEST 1
2. **Check table data** - Run TEST 2  
3. **Get real user IDs** - Run TEST 3
4. **Test function directly** - Run TEST 4
5. **Check RLS policies** - Run TEST 5

### Step 3: Run Minimal Test
If the above steps don't work, run `sql/minimal_test.sql` which creates test data and verifies basic functionality.

## Common Issues and Solutions

### Issue 1: Functions Don't Exist
**Symptoms**: TEST 1 returns no rows
**Solution**: Re-run `sql/complete_fix.sql`

### Issue 2: No Users with Preferences  
**Symptoms**: TEST 3 shows users but `preference_id` is NULL
**Solution**: The complete_fix.sql handles this automatically

### Issue 3: No Reading Content
**Symptoms**: Function exists, user has preference, but no data returned
**Solution**: The complete_fix.sql adds sample reading content

### Issue 4: RLS Policies Blocking Access
**Symptoms**: Function works in SQL Editor but fails in app
**Solution**: Check TEST 5 results and update RLS policies

### Issue 5: User Not in Custom Users Table
**Symptoms**: User authenticated in app but doesn't exist in `users` table
**Solution**: Add user to `users` table:

```sql
INSERT INTO users (id, email, preference_id) 
VALUES ('your-auth-user-id', 'user@email.com', 'pref-programming-001')
ON CONFLICT (id) DO UPDATE SET preference_id = 'pref-programming-001';
```

## Verification Steps

### 1. Test in SQL Editor
```sql
-- Replace with your actual user ID from the app
SELECT * FROM get_today_reading('your-user-id'::uuid);
```

### 2. Check App Logs
Look for more specific error messages after applying the enhanced error handling.

### 3. Test Authentication
Verify the user ID being passed from the Flutter app matches what exists in your database.

## Enhanced Error Messages

The updated Dart code now provides specific error messages:
- "RPC function get_today_reading does not exist" - Function missing
- "Database tables missing" - Schema issue  
- "Database schema mismatch" - Column missing
- "Permission denied" - RLS policy issue
- Full error details for debugging

## Final Validation

After applying the complete fix:

1. **Functions should exist**: 4 functions in Supabase Dashboard > Database > Functions
2. **Test data should exist**: Users with preferences, reading subjects, daily readings
3. **App should work**: Daily reading card loads without errors
4. **Full flow works**: Can complete readings and see progress

## Files Reference

- `sql/complete_fix.sql` - Complete solution with functions and data
- `sql/debug_step_by_step.sql` - Step-by-step debugging  
- `sql/minimal_test.sql` - Minimal working test
- `sql/verify_setup.sql` - Comprehensive verification

## Next Steps

1. Run `sql/complete_fix.sql` in Supabase SQL Editor
2. Copy a user ID from the test results
3. Test the function with that user ID
4. If it works in SQL but not in app, check authentication and RLS policies
5. Test the Flutter app

The issue should be resolved after running the complete fix script!
