-- FIX FOR "structure of query does not match function result type" ERROR
-- This SQL script addresses the specific PostgreSQL error by ensuring exact type matching

-- ============================================================================
-- STEP 1: Drop existing functions to avoid conflicts
-- ============================================================================

DROP FUNCTION IF EXISTS get_daily_reading(UUID);
DROP FUNCTION IF EXISTS generate_daily_reading(UUID);
DROP FUNCTION IF EXISTS submit_reading_feedback(UUID, UUID, VARCHAR);
DROP FUNCTION IF EXISTS mark_reading_as_read(UUID, UUID);
DROP FUNCTION IF EXISTS get_user_preferences(UUID);

-- ============================================================================
-- STEP 2: Create corrected functions with exact type matching
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
        SELECT 1 FROM daily_readings dr
        WHERE dr.user_id = p_user_id 
        AND dr.reading_date = CURRENT_DATE
    ) THEN
        RETURN; -- Already has reading for today
    END IF;

    -- Simple selection of a random reading
    SELECT r.id INTO selected_reading_id
    FROM readings r
    WHERE r.is_active = true
    AND r.id NOT IN (
        -- Exclude recently read articles (last 30 days)
        SELECT dr2.reading_id 
        FROM daily_readings dr2
        WHERE dr2.user_id = p_user_id 
        AND dr2.reading_date > CURRENT_DATE - INTERVAL '30 days'
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

    -- Return the daily reading with exact type casting and qualified column references
    RETURN QUERY
    SELECT 
        dr.id,
        COALESCE(r.title, '')::TEXT as title,
        COALESCE(r.content, '')::TEXT as content,
        COALESCE(r.quote, '')::TEXT as quote,
        COALESCE(s.name, 'General')::TEXT as scope_name,
        dr.reading_date,  -- Properly qualified with table alias
        COALESCE(dr.is_read, false) as is_read,
        COALESCE(rf.feedback_type, '')::TEXT as user_feedback
    FROM daily_readings dr
    JOIN readings r ON dr.reading_id = r.id
    LEFT JOIN scopes s ON r.scope_id = s.id
    LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
    WHERE dr.user_id = p_user_id
    AND dr.reading_date = CURRENT_DATE  -- Properly qualified with table alias
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
    -- Update daily_readings to mark as read
    UPDATE daily_readings 
    SET is_read = true
    WHERE user_id = p_user_id 
    AND reading_id = p_reading_id
    AND reading_date = CURRENT_DATE;

    GET DIAGNOSTICS rows_updated = ROW_COUNT;

    -- Return result based on update success
    IF rows_updated > 0 THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Reading marked as read'
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'message', 'Reading not found or already marked as read'
        );
    END IF;
END;
$$;

-- Function to submit reading feedback (returns simple JSON)
CREATE OR REPLACE FUNCTION submit_reading_feedback(
    p_user_id UUID,
    p_reading_id UUID,
    p_feedback_type TEXT  -- Changed from VARCHAR to TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Validate feedback type
    IF p_feedback_type NOT IN ('up', 'down') THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Invalid feedback type. Must be "up" or "down"'
        );
    END IF;

    -- Insert or update feedback
    INSERT INTO reading_feedbacks (user_id, reading_id, feedback_type)
    VALUES (p_user_id, p_reading_id, p_feedback_type)
    ON CONFLICT (user_id, reading_id) 
    DO UPDATE SET 
        feedback_type = EXCLUDED.feedback_type,
        updated_at = NOW();

    RETURN json_build_object(
        'success', true,
        'message', 'Feedback submitted successfully',
        'feedback_type', p_feedback_type
    );
END;
$$;

-- Function to get user preferences (simplified)
CREATE OR REPLACE FUNCTION get_user_preferences(p_user_id UUID)
RETURNS TABLE (
    preference_id UUID,
    preference_name TEXT,
    scope_id UUID,
    scope_name TEXT,
    scope_weight INTEGER,
    scope_description TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as preference_id,
        COALESCE(p.preferences_name, '')::TEXT as preference_name,
        s.id as scope_id,
        COALESCE(s.name, '')::TEXT as scope_name,
        COALESCE(s.weight, 0) as scope_weight,
        COALESCE(s.description, '')::TEXT as scope_description
    FROM users u
    LEFT JOIN preferences p ON u.preference_id = p.id
    LEFT JOIN scopes s ON s.preference_id = p.id
    WHERE u.id = p_user_id
    AND u.preference_id IS NOT NULL;
END;
$$;

-- ============================================================================
-- STEP 3: Test the functions with simple queries
-- ============================================================================

-- Test query to verify function works (uncomment to test manually)
-- SELECT * FROM get_daily_reading('YOUR_USER_ID_HERE');

-- ============================================================================
-- STEP 4: Grant necessary permissions
-- ============================================================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION generate_daily_reading(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_daily_reading(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_reading_as_read(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION submit_reading_feedback(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_preferences(UUID) TO authenticated;

-- ============================================================================
-- VERIFICATION: Run these queries to test if functions work
-- ============================================================================

-- 1. Test function exists and has correct signature
SELECT 
    p.proname as function_name,
    pg_get_function_result(p.oid) as return_type,
    pg_get_function_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname IN ('get_daily_reading', 'generate_daily_reading', 'submit_reading_feedback', 'mark_reading_as_read');

-- 2. Test basic function call (this should not throw structure error)
-- Note: This will fail if no user/reading data exists, but should not give structure error
-- SELECT 'Function structure test passed' as result;
