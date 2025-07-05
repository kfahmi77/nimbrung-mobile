# Daily Reading System Database Setup & Troubleshooting

## Database Schema Compatibility

Your existing database schema has been analyzed and the SQL functions have been updated to match:

### Key Schema Differences Addressed:

1. **Table Names**:

   - Using `preferences` instead of `user_preferences`
   - Using existing `users`, `scopes`, `readings`, `daily_readings`, `reading_feedbacks` tables

2. **Relationship Structure**:

   - `users.preference_id` → `preferences.id` (your schema)
   - `scopes.preference_id` → `preferences.id` (your schema)

3. **Field Names**:
   - `preferences.preferences_name` (your field name)
   - All other fields match your schema

## Setup Steps

### 1. Apply Updated SQL Functions

Run the SQL from `sql/daily_reading_system_fixed.sql` in your Supabase dashboard:

```sql
-- This file contains updated RPC functions that match your schema
-- It includes: get_daily_reading, submit_reading_feedback, mark_reading_as_read
```

### 2. Verify Required Data

Ensure you have at least:

```sql
-- Check if you have preferences
SELECT * FROM preferences;

-- Check if you have scopes with weights
SELECT * FROM scopes WHERE weight > 0;

-- Check if you have active readings
SELECT * FROM readings WHERE is_active = true;

-- Check if users have preference_id set
SELECT id, username, preference_id FROM users WHERE preference_id IS NOT NULL;
```

### 3. Common Database Errors & Solutions

#### Error: "function get_daily_reading does not exist"

**Solution**: Apply the updated SQL functions from `sql/daily_reading_system_fixed.sql`

#### Error: "relation user_preferences does not exist"

**Solution**: The functions have been updated to use your `preferences` table instead

#### Error: "column preferences_name does not exist"

**Solution**: The functions now use `preferences_name` field as in your schema

#### Error: "No daily reading found"

**Possible Causes**:

1. User has no `preference_id` set
2. No scopes exist for the user's preference
3. No active readings exist
4. All readings have been read in the last 30 days

**Debug Steps**:

```sql
-- Check user's preference
SELECT u.id, u.username, u.preference_id, p.preferences_name
FROM users u
LEFT JOIN preferences p ON u.preference_id = p.id
WHERE u.id = 'YOUR_USER_ID';

-- Check scopes for user's preference
SELECT s.* FROM scopes s
JOIN users u ON s.preference_id = u.preference_id
WHERE u.id = 'YOUR_USER_ID';

-- Check available readings
SELECT r.* FROM readings r
WHERE r.is_active = true
AND r.id NOT IN (
    SELECT reading_id FROM daily_readings
    WHERE user_id = 'YOUR_USER_ID'
    AND reading_date > CURRENT_DATE - INTERVAL '30 days'
);
```

### 4. Testing the Setup

#### Test RPC Functions Manually:

```sql
-- Test get_daily_reading
SELECT * FROM get_daily_reading('YOUR_USER_ID');

-- Test submit_reading_feedback
SELECT * FROM submit_reading_feedback('USER_ID', 'READING_ID', 'up');

-- Test mark_reading_as_read
SELECT * FROM mark_reading_as_read('USER_ID', 'READING_ID');
```

#### Test Flutter App:

1. **Check Logs**: Look for detailed logs from each layer:

   - `DailyReadingCard` - Widget level
   - `DailyReadingProvider` - State management
   - `DailyReadingRemoteDataSource` - API calls

2. **Common Log Patterns**:

   ```
   [DailyReadingCard] Widget: Current user found: abc123
   [DailyReadingProvider] Provider: Getting daily reading for user: abc123
   [DailyReadingRemoteDataSource] Starting getDailyReading for user: abc123
   [DailyReadingRemoteDataSource] Calling get_daily_reading RPC function
   [DailyReadingRemoteDataSource] RPC response received: {...}
   ```

3. **Error Identification**:
   - **Authentication Error**: No user found logs
   - **Database Error**: PostgrestException in logs
   - **Data Error**: Empty response or parsing errors
   - **RPC Error**: Function not found errors

### 5. Sample Data Setup

If you need sample data for testing:

```sql
-- Insert sample preference
INSERT INTO preferences (preferences_name) VALUES ('Psikologi');

-- Get the preference ID
SELECT id FROM preferences WHERE preferences_name = 'Psikologi';

-- Update a user to have this preference
UPDATE users SET preference_id = (SELECT id FROM preferences WHERE preferences_name = 'Psikologi' LIMIT 1) WHERE id = 'YOUR_USER_ID';

-- Insert sample scopes
INSERT INTO scopes (name, preference_id, weight, description) VALUES
('Psikologi Kognitif', (SELECT id FROM preferences WHERE preferences_name = 'Psikologi' LIMIT 1), 5, 'Mental processes'),
('Psikologi Sosial', (SELECT id FROM preferences WHERE preferences_name = 'Psikologi' LIMIT 1), 3, 'Social interactions');

-- Insert sample reading
INSERT INTO readings (title, content, quote, scope_id, is_active) VALUES
('Test Reading', 'This is a test reading content for daily reading system.', 'Test quote', (SELECT id FROM scopes WHERE name = 'Psikologi Kognitif' LIMIT 1), true);
```

## Troubleshooting Checklist

- [ ] SQL functions applied to Supabase
- [ ] User has `preference_id` set in `users` table
- [ ] Preferences exist in `preferences` table
- [ ] Scopes exist with `weight > 0`
- [ ] Active readings exist (`is_active = true`)
- [ ] User is authenticated in Flutter app
- [ ] Network connectivity is working
- [ ] Supabase project is accessible

## Support

If you continue to see errors, please share:

1. The exact error message from logs
2. The user ID you're testing with
3. Results of the debug SQL queries above
