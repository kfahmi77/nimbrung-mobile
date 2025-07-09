# Fix for Mark Reading as Read Error

## 🚨 **ERROR REPORTED**
```
[DailyReadingRemoteDataSource] Mark as read response: {success: false, message: column "updated_at" of relation "daily_readings" does not exist}
```

## 🔍 **ROOT CAUSE ANALYSIS**

The error occurs because the `mark_reading_as_read` function is trying to update a column that doesn't exist in the `daily_readings` table.

### Current Problematic Function:
```sql
UPDATE daily_readings 
SET 
    is_read = true,
    updated_at = NOW()  -- ❌ This column doesn't exist!
WHERE user_id = p_user_id 
AND reading_id = p_reading_id 
AND reading_date = CURRENT_DATE;
```

### Actual daily_readings Schema:
```sql
create table public.daily_readings (
  id uuid not null default gen_random_uuid (),
  user_id uuid not null,
  reading_id uuid not null,
  reading_date date not null,
  is_read boolean null default false,
  created_at timestamp with time zone null default now(),
  -- ❌ NO updated_at column exists!
  constraint daily_readings_pkey primary key (id),
  constraint daily_readings_user_id_reading_date_key unique (user_id, reading_date),
  constraint daily_readings_user_id_fkey foreign KEY (user_id) references users (id) on delete CASCADE,
  constraint daily_readings_reading_id_fkey foreign KEY (reading_id) references readings (id) on delete CASCADE
);
```

## ✅ **SOLUTION**

The fix removes the non-existent `updated_at` column reference from the UPDATE statement.

### Fixed Function:
```sql
CREATE OR REPLACE FUNCTION mark_reading_as_read(
    p_user_id UUID,
    p_reading_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Update daily reading to mark as read
    -- Note: Removed updated_at column as it doesn't exist in daily_readings table
    UPDATE daily_readings 
    SET is_read = true
    WHERE user_id = p_user_id 
    AND reading_id = p_reading_id 
    AND reading_date = CURRENT_DATE;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Daily reading not found for today'
        );
    END IF;
    
    RETURN json_build_object(
        'success', true,
        'message', 'Reading marked as read successfully'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$;
```

## 🚀 **DEPLOYMENT INSTRUCTIONS**

### Option 1: Apply Complete Fix
```sql
-- Apply the comprehensive fix file (includes this fix + other improvements)
\i sql/comprehensive_daily_reading_fix.sql
```

### Option 2: Apply Only This Specific Fix
```sql
-- Just fix the mark_reading_as_read function
CREATE OR REPLACE FUNCTION mark_reading_as_read(
    p_user_id UUID,
    p_reading_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    UPDATE daily_readings 
    SET is_read = true
    WHERE user_id = p_user_id 
    AND reading_id = p_reading_id 
    AND reading_date = CURRENT_DATE;
    
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Daily reading not found for today'
        );
    END IF;
    
    RETURN json_build_object(
        'success', true,
        'message', 'Reading marked as read successfully'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$;

GRANT EXECUTE ON FUNCTION mark_reading_as_read(UUID, UUID) TO authenticated;
```

## 🧪 **VERIFICATION**

After applying the fix, test the function:

```sql
-- Test with a valid user and reading ID
SELECT mark_reading_as_read('YOUR_USER_ID', 'YOUR_READING_ID');
```

Expected success response:
```json
{
  "success": true,
  "message": "Reading marked as read successfully"
}
```

## 📱 **FLUTTER APP IMPACT**

No changes needed in the Flutter app. The existing code will work once the SQL function is fixed:

```dart
final response = await _supabase.rpc(
  'mark_reading_as_read',
  params: {'p_user_id': userId, 'p_reading_id': readingId},
);
// Will now return success: true instead of the error
```

## 🔍 **OTHER FUNCTIONS CHECKED**

✅ **`generate_daily_readings_for_all_users`** - No changes needed, doesn't reference updated_at in daily_readings  
✅ **Other daily reading functions** - All verified, only mark_reading_as_read had this issue

---

**Status**: 🟢 **READY FOR IMMEDIATE DEPLOYMENT**  
**Impact**: ✅ **Fixes the mark-as-read functionality error**  
**Risk**: 🟢 **Very Low - Only removes non-existent column reference**

*Apply the fix and the mark-as-read functionality will work correctly.*
