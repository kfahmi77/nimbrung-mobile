# QUICK FIX for "daily_readings does not exist" Error

## The Problem

You have the tables in your database, but the RPC functions were created with an empty `search_path` which prevents them from finding the tables.

## The Solution

### Step 1: Apply the Fixed RPC Functions

1. **Open your Supabase dashboard** and go to the **SQL Editor**
2. **Copy and paste** the entire contents of `sql/fixed_rpc_functions.sql` into the SQL Editor
3. **Click "Run"** to execute the script

This will:

- Drop the old broken functions
- Create new functions with proper `public.` schema references
- Add the necessary sample data

### Step 2: Test the Fix

1. **Copy and paste** the entire contents of `sql/test_after_fix.sql` into the SQL Editor
2. **Click "Run"** to verify everything is working

You should see:

- ✅ EXISTS for all tables and functions
- Row counts showing data exists
- A successful test of the `get_today_reading` function

### Step 3: Test Your Flutter App

After the SQL scripts run successfully, your Flutter app should now be able to:

- Load the daily reading card on the homepage
- Display reading content properly
- Handle completion actions

## What Was Fixed

- Removed `SET search_path = ''` from functions
- Added explicit `public.` schema references to all table names
- Ensured sample data is properly inserted

## Troubleshooting

If you still get errors:

1. Check that your user ID `'23a5b62e-8c35-440e-af6e-e033577aa0b4'` exists in the `users` table
2. Ensure your user has a valid `preference_id`
3. Verify RLS (Row Level Security) policies if needed

The key fix was changing from:

```sql
FROM daily_readings dr
```

to:

```sql
FROM public.daily_readings dr
```

This ensures the function can always find the tables regardless of the search path.
