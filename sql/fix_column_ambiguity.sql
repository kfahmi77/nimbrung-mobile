-- FIX FOR COLUMN AMBIGUITY ERROR: "column reference 'reading_date' is ambiguous"
-- This SQL script fixes the ambiguity in column references by properly qualifying all columns

-- ============================================================================
-- STEP 1: Drop existing functions to avoid conflicts
-- ============================================================================

DROP FUNCTION IF EXISTS get_daily_reading(UUID);
DROP FUNCTION IF EXISTS generate_daily_reading(UUID);
DROP FUNCTION IF EXISTS submit_reading_feedback(UUID, UUID, VARCHAR);
DROP FUNCTION IF EXISTS mark_reading_as_read(UUID, UUID);
DROP FUNCTION IF EXISTS get_user_preferences(UUID);

-- ============================================================================
-- STEP 2: Create corrected functions with properly qualified column references
-- ============================================================================

-- Function to generate daily reading (simple void function)
CREATE OR REPLACE FUNCTION generate_daily_reading(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    selected_reading_id UUID;
BEGIN
    -- Check if user already has a reading for today
    IF EXISTS (
        SELECT 1 FROM daily_readings dr_check
        WHERE dr_check.user_id = p_user_id 
        AND dr_check.reading_date = CURRENT_DATE
    ) THEN
        RETURN; -- Already has reading for today
    END IF;

    -- Simple selection of a random reading
    SELECT r.id INTO selected_reading_id
    FROM readings r
    WHERE r.is_active = true
    AND r.id NOT IN (
        -- Exclude recently read articles (last 30 days)
        -- Fix: Use fully qualified column reference
        SELECT dr_recent.reading_id 
        FROM daily_readings dr_recent
        WHERE dr_recent.user_id = p_user_id 
        AND dr_recent.reading_date > (CURRENT_DATE - INTERVAL '30 days')
    )
    ORDER BY RANDOM()
    LIMIT 1;

    -- Insert the selected reading if we found one
    IF selected_reading_id IS NOT NULL THEN
        INSERT INTO daily_readings (user_id, reading_id, reading_date)
        VALUES (p_user_id, selected_reading_id, CURRENT_DATE);
    END IF;
END;
$$;

-- Function to get daily reading with exact column type matching
CREATE OR REPLACE FUNCTION get_daily_reading(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    title TEXT,
    content TEXT,
    quote TEXT,
    scope_name TEXT,
    reading_date DATE,
    is_read BOOLEAN,
    user_feedback TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    daily_reading_exists BOOLEAN := FALSE;
BEGIN
    -- Check if daily reading exists for today
    SELECT EXISTS(
        SELECT 1 FROM daily_readings dr_check
        WHERE dr_check.user_id = p_user_id 
        AND dr_check.reading_date = CURRENT_DATE
    ) INTO daily_reading_exists;

    -- If no reading exists for today, generate one
    IF NOT daily_reading_exists THEN
        PERFORM generate_daily_reading(p_user_id);
    END IF;

    -- Return the daily reading with exact type casting and properly qualified column references
    -- FIX: Return r.id (readings.id) instead of dr.id (daily_readings.id) for proper foreign key reference
    RETURN QUERY
    SELECT 
        r.id,  -- This should be readings.id for proper feedback submission
        COALESCE(r.title, '')::TEXT as title,
        COALESCE(r.content, '')::TEXT as content,
        COALESCE(r.quote, '')::TEXT as quote,
        COALESCE(s.name, 'General')::TEXT as scope_name,
        dr.reading_date::DATE,  -- Explicitly qualified and cast
        COALESCE(dr.is_read, false)::BOOLEAN as is_read,
        COALESCE(rf.feedback_type, '')::TEXT as user_feedback
    FROM daily_readings dr
    JOIN readings r ON dr.reading_id = r.id
    LEFT JOIN scopes s ON r.scope_id = s.id
    LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
    WHERE dr.user_id = p_user_id
    AND dr.reading_date = CURRENT_DATE  -- Explicitly qualified
    LIMIT 1;
END;
$$;

-- Function to mark reading as read (returns simple JSON)
CREATE OR REPLACE FUNCTION mark_reading_as_read(p_user_id UUID, p_reading_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    rows_updated INTEGER;
BEGIN
    -- Update the daily_readings table to mark as read
    UPDATE daily_readings dr
    SET is_read = true
    WHERE dr.user_id = p_user_id 
    AND dr.reading_id = p_reading_id
    AND dr.reading_date = CURRENT_DATE;
    
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    
    -- Return simple JSON response
    IF rows_updated > 0 THEN
        RETURN json_build_object('success', true, 'message', 'Reading marked as read');
    ELSE
        RETURN json_build_object('success', false, 'message', 'Reading not found or already marked');
    END IF;
END;
$$;

-- Function to submit reading feedback (returns simple JSON)
CREATE OR REPLACE FUNCTION submit_reading_feedback(p_user_id UUID, p_reading_id UUID, p_feedback_type VARCHAR)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Validate that the reading exists
    IF NOT EXISTS (SELECT 1 FROM readings WHERE id = p_reading_id) THEN
        RETURN json_build_object('success', false, 'message', 'Reading not found');
    END IF;

    -- Validate feedback type
    IF p_feedback_type NOT IN ('up', 'down', 'liked', 'disliked') THEN
        RETURN json_build_object('success', false, 'message', 'Invalid feedback type');
    END IF;

    -- Insert or update feedback (handle both created_at and updated_at columns)
    INSERT INTO reading_feedbacks (user_id, reading_id, feedback_type, created_at, updated_at)
    VALUES (p_user_id, p_reading_id, p_feedback_type, NOW(), NOW())
    ON CONFLICT (user_id, reading_id) 
    DO UPDATE SET 
        feedback_type = EXCLUDED.feedback_type,
        updated_at = NOW();
    
    -- Return simple JSON response
    RETURN json_build_object('success', true, 'message', 'Feedback submitted successfully');
EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN json_build_object('success', false, 'message', 'Invalid reading ID or user ID');
    WHEN unique_violation THEN
        RETURN json_build_object('success', false, 'message', 'Feedback already exists');
    WHEN OTHERS THEN
        RETURN json_build_object('success', false, 'message', 'Failed to submit feedback: ' || SQLERRM);
END;
$$;

-- Function to get user preferences (returns simple JSON)
CREATE OR REPLACE FUNCTION get_user_preferences(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    result JSON;
BEGIN
    -- Get user preferences through the users table
    SELECT json_build_object(
        'daily_reading_enabled', COALESCE(p.daily_reading_enabled, true),
        'preferred_reading_time', COALESCE(p.preferred_reading_time, '09:00:00'),
        'reading_difficulty', COALESCE(p.reading_difficulty, 'medium'),
        'notification_enabled', COALESCE(p.notification_enabled, true)
    ) INTO result
    FROM users u
    LEFT JOIN preferences p ON u.preference_id = p.id
    WHERE u.id = p_user_id;
    
    -- Return the preferences or default values
    RETURN COALESCE(result, json_build_object(
        'daily_reading_enabled', true,
        'preferred_reading_time', '09:00:00',
        'reading_difficulty', 'medium',
        'notification_enabled', true
    ));
END;
$$;

-- ============================================================================
-- STEP 3: Grant necessary permissions
-- ============================================================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION generate_daily_reading(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_daily_reading(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_reading_as_read(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION submit_reading_feedback(UUID, UUID, VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_preferences(UUID) TO authenticated;

-- ============================================================================
-- STEP 4: Test queries to verify the fix
-- ============================================================================

-- Test the functions with a sample user ID
-- Replace 'your-user-id-here' with an actual user ID from your users table

/*
-- Test 1: Generate daily reading
SELECT generate_daily_reading('your-user-id-here'::UUID);

-- Test 2: Get daily reading
SELECT * FROM get_daily_reading('your-user-id-here'::UUID);

-- Test 3: Get user preferences
SELECT get_user_preferences('your-user-id-here'::UUID);

-- Test 4: Mark reading as read (use actual reading_id)
SELECT mark_reading_as_read('your-user-id-here'::UUID, 'your-reading-id-here'::UUID);

-- Test 5: Submit feedback (use actual reading_id)
SELECT submit_reading_feedback('your-user-id-here'::UUID, 'your-reading-id-here'::UUID, 'liked');
*/

-- ============================================================================
-- DOCUMENTATION: What was fixed
-- ============================================================================

/*
COLUMN AMBIGUITY AND FOREIGN KEY FIXES:

1. In generate_daily_reading():
   - Changed alias from 'dr2' to 'dr_recent' for clarity
   - Added parentheses around date calculation: (CURRENT_DATE - INTERVAL '30 days')
   - Used fully qualified column references: dr_recent.reading_date, dr_recent.user_id

2. In get_daily_reading():
   - FIX: Return r.id (readings.id) instead of dr.id (daily_readings.id) for proper foreign key reference
   - Added explicit type casting: dr.reading_date::DATE
   - Ensured all column references are properly qualified with table aliases
   - Used consistent alias naming: dr_check, dr, r, s, rf

3. In mark_reading_as_read():
   - Added explicit table alias 'dr' for daily_readings
   - Qualified all column references: dr.user_id, dr.reading_id, dr.reading_date
   - Function now correctly receives readings.id as input parameter

4. In submit_reading_feedback():
   - Added validation for reading existence
   - Added validation for feedback type
   - Enhanced error handling for foreign key violations
   - Now correctly receives readings.id as input parameter

5. General improvements:
   - Consistent use of table aliases throughout all functions
   - Explicit type casting where needed
   - Clear separation of subquery aliases to avoid conflicts
   - Added parentheses around complex date expressions
   - Fixed foreign key constraint issues by returning correct reading IDs

The "column reference 'reading_date' is ambiguous" error should now be resolved
and the "foreign key constraint violation" error should also be fixed because
all functions now use the correct readings.id for cross-table references.
*/

3. In mark_reading_as_read():
   - Added explicit table alias 'dr' for daily_readings
   - Qualified all column references: dr.user_id, dr.reading_id, dr.reading_date

4. General improvements:
   - Consistent use of table aliases throughout all functions
   - Explicit type casting where needed
   - Clear separation of subquery aliases to avoid conflicts
   - Added parentheses around complex date expressions

The "column reference 'reading_date' is ambiguous" error should now be resolved
because all column references are explicitly qualified with their table aliases.
*/
