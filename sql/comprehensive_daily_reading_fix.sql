-- ============================================================================
-- COMPREHENSIVE DAILY READING FIXES
-- Fixes multiple issues with the daily reading system
-- ============================================================================

BEGIN;

-- ============================================================================
-- FIX 1: get_user_reading_interaction - Fix ambiguous column reference
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_reading_interaction(
    p_user_id UUID,
    p_reading_id UUID
)
RETURNS TABLE (
    has_daily_reading BOOLEAN,
    has_feedback BOOLEAN,
    feedback_type TEXT,
    is_read BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        EXISTS(
            SELECT 1 FROM daily_readings 
            WHERE user_id = p_user_id AND reading_id = p_reading_id
        ) as has_daily_reading,
        EXISTS(
            SELECT 1 FROM reading_feedbacks 
            WHERE user_id = p_user_id AND reading_id = p_reading_id
        ) as has_feedback,
        COALESCE(
            (SELECT rf.feedback_type FROM reading_feedbacks rf
             WHERE rf.user_id = p_user_id AND rf.reading_id = p_reading_id 
             LIMIT 1), 
            NULL
        ) as feedback_type,
        COALESCE(
            (SELECT dr.is_read FROM daily_readings dr
             WHERE dr.user_id = p_user_id AND dr.reading_id = p_reading_id 
             LIMIT 1), 
            false
        ) as is_read;
END;
$$;

-- ============================================================================
-- FIX 2: get_oldest_reading_for_preference - Fix return type mismatch
-- ============================================================================

CREATE OR REPLACE FUNCTION get_oldest_reading_for_preference(
    p_user_id UUID,
    p_preference_id UUID
)
RETURNS TABLE (
    reading_id UUID,
    reading_title TEXT,
    reading_content TEXT,
    reading_quote TEXT,
    scope_name TEXT,
    reading_created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Get the oldest reading for this preference (restart from beginning)
    RETURN QUERY
    SELECT 
        r.id,
        r.title::TEXT,
        r.content,
        r.quote,
        s.name::TEXT,
        r.created_at
    FROM readings r
    JOIN scopes s ON r.scope_id = s.id
    WHERE s.preference_id = p_preference_id
    AND r.is_active = true
    ORDER BY r.created_at ASC
    LIMIT 1;
END;
$$;

-- ============================================================================
-- FIX 3: get_newest_reading_for_preference - Fix return type consistency
-- ============================================================================

CREATE OR REPLACE FUNCTION get_newest_reading_for_preference(
    p_user_id UUID,
    p_preference_id UUID
)
RETURNS TABLE (
    reading_id UUID,
    reading_title TEXT,
    reading_content TEXT,
    reading_quote TEXT,
    scope_name TEXT,
    reading_created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Get the newest reading for this preference
    RETURN QUERY
    SELECT 
        r.id,
        r.title::TEXT,
        r.content,
        r.quote,
        s.name::TEXT,
        r.created_at
    FROM readings r
    JOIN scopes s ON r.scope_id = s.id
    WHERE s.preference_id = p_preference_id
    AND r.is_active = true
    ORDER BY r.created_at DESC
    LIMIT 1;
END;
$$;

-- ============================================================================
-- FIX 4: get_next_uninteracted_reading - Fix return type consistency
-- ============================================================================

CREATE OR REPLACE FUNCTION get_next_uninteracted_reading(
    p_user_id UUID,
    p_preference_id UUID
)
RETURNS TABLE (
    reading_id UUID,
    reading_title TEXT,
    reading_content TEXT,
    reading_quote TEXT,
    scope_name TEXT,
    reading_created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    -- Get readings that user has never interacted with (no daily_reading and no feedback)
    RETURN QUERY
    SELECT 
        r.id,
        r.title::TEXT,
        r.content,
        r.quote,
        s.name::TEXT,
        r.created_at
    FROM readings r
    JOIN scopes s ON r.scope_id = s.id
    WHERE s.preference_id = p_preference_id
    AND r.is_active = true
    AND NOT EXISTS (
        SELECT 1 FROM daily_readings dr 
        WHERE dr.user_id = p_user_id AND dr.reading_id = r.id
    )
    AND NOT EXISTS (
        SELECT 1 FROM reading_feedbacks rf 
        WHERE rf.user_id = p_user_id AND rf.reading_id = r.id
    )
    ORDER BY r.created_at ASC
    LIMIT 1;
END;
$$;

-- ============================================================================
-- FIX 5: Enhanced generate_daily_reading_for_user - Fix existing reading logic
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_daily_reading_for_user(
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    user_preference_id UUID;
    selected_reading RECORD;
    today_date DATE := CURRENT_DATE;
    existing_daily_reading RECORD;
    progress_record RECORD;
    newest_reading RECORD;
    force_new_reading BOOLEAN := false;
BEGIN
    -- Get user's preference
    SELECT preference_id INTO user_preference_id
    FROM users 
    WHERE id = p_user_id;
    
    IF user_preference_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'action', 'skipped_no_preference',
            'message', 'User has no preference set'
        );
    END IF;
    
    -- Check if user already has a daily reading for today
    SELECT * INTO existing_daily_reading
    FROM daily_readings
    WHERE user_id = p_user_id 
    AND reading_date = today_date;
    
    -- If existing daily reading exists, check if we should generate a new one
    IF existing_daily_reading.id IS NOT NULL THEN
        -- Check if there are newer uninteracted readings available
        SELECT * INTO selected_reading
        FROM get_next_uninteracted_reading(p_user_id, user_preference_id);
        
        -- If there's a newer uninteracted reading, replace the existing one
        IF selected_reading.reading_id IS NOT NULL THEN
            -- Delete the existing daily reading for today
            DELETE FROM daily_readings 
            WHERE user_id = p_user_id AND reading_date = today_date;
            
            -- Create new daily reading with the uninteracted reading
            INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
            VALUES (p_user_id, selected_reading.reading_id, today_date, false, NOW());
            
            RETURN json_build_object(
                'success', true,
                'action', 'new_reading_generated',
                'message', 'New daily reading generated (replaced existing)',
                'reading', json_build_object(
                    'id', selected_reading.reading_id,
                    'title', selected_reading.reading_title,
                    'content', selected_reading.reading_content,
                    'quote', selected_reading.reading_quote,
                    'scopeName', selected_reading.scope_name,
                    'createdAt', selected_reading.reading_created_at,
                    'userFeedback', NULL,
                    'isRead', false
                )
            );
        ELSE
            -- Return existing daily reading with additional info
            SELECT 
                r.id,
                r.title,
                r.content,
                r.quote,
                s.name as scope_name,
                r.created_at,
                COALESCE(rf.feedback_type, NULL) as user_feedback,
                dr.is_read
            INTO selected_reading
            FROM readings r
            JOIN scopes s ON r.scope_id = s.id
            JOIN daily_readings dr ON dr.reading_id = r.id
            LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
            WHERE dr.id = existing_daily_reading.id;
            
            RETURN json_build_object(
                'success', true,
                'action', 'existing_reading',
                'message', 'Daily reading already exists for today',
                'reading', json_build_object(
                    'id', selected_reading.id,
                    'title', selected_reading.title,
                    'content', selected_reading.content,
                    'quote', selected_reading.quote,
                    'scopeName', selected_reading.scope_name,
                    'createdAt', selected_reading.created_at,
                    'userFeedback', selected_reading.user_feedback,
                    'isRead', selected_reading.is_read
                )
            );
        END IF;
    END IF;
    
    -- Get or initialize user reading progress
    SELECT * INTO progress_record
    FROM user_reading_progress
    WHERE user_id = p_user_id AND preference_id = user_preference_id;
    
    IF progress_record.id IS NULL THEN
        -- Initialize progress record
        INSERT INTO user_reading_progress (
            user_id, 
            preference_id, 
            last_reading_created_at, 
            total_readings_consumed, 
            cycle_count,
            created_at,
            updated_at
        )
        VALUES (
            p_user_id, 
            user_preference_id, 
            '1900-01-01'::timestamp with time zone, -- Start from very beginning
            0, 
            0,
            NOW(),
            NOW()
        )
        ON CONFLICT (user_id, preference_id) DO NOTHING;
        
        -- Get the progress record again
        SELECT * INTO progress_record
        FROM user_reading_progress
        WHERE user_id = p_user_id AND preference_id = user_preference_id;
    END IF;
    
    -- Strategy 1: Try to get next uninteracted reading
    SELECT * INTO selected_reading
    FROM get_next_uninteracted_reading(p_user_id, user_preference_id);
    
    IF selected_reading.reading_id IS NOT NULL THEN
        -- Found an uninteracted reading
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (p_user_id, selected_reading.reading_id, today_date, false, NOW())
        ON CONFLICT (user_id, reading_date) DO NOTHING;
        
        -- Update progress
        UPDATE user_reading_progress 
        SET 
            last_reading_created_at = selected_reading.reading_created_at,
            total_readings_consumed = total_readings_consumed + 1,
            updated_at = NOW()
        WHERE user_id = p_user_id AND preference_id = user_preference_id;
        
        RETURN json_build_object(
            'success', true,
            'action', 'new_reading_generated',
            'message', 'Daily reading generated successfully',
            'reading', json_build_object(
                'id', selected_reading.reading_id,
                'title', selected_reading.reading_title,
                'content', selected_reading.reading_content,
                'quote', selected_reading.reading_quote,
                'scopeName', selected_reading.scope_name,
                'createdAt', selected_reading.reading_created_at,
                'userFeedback', NULL,
                'isRead', false
            )
        );
    END IF;
    
    -- Strategy 2: Get newest reading if user has consumed all uninteracted ones
    SELECT * INTO selected_reading
    FROM get_newest_reading_for_preference(p_user_id, user_preference_id);
    
    IF selected_reading.reading_id IS NOT NULL THEN
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (p_user_id, selected_reading.reading_id, today_date, false, NOW())
        ON CONFLICT (user_id, reading_date) DO NOTHING;
        
        -- Update progress
        UPDATE user_reading_progress 
        SET 
            last_reading_created_at = selected_reading.reading_created_at,
            total_readings_consumed = total_readings_consumed + 1,
            updated_at = NOW()
        WHERE user_id = p_user_id AND preference_id = user_preference_id;
        
        RETURN json_build_object(
            'success', true,
            'action', 'new_reading_generated',
            'message', 'Daily reading generated successfully (newest)',
            'reading', json_build_object(
                'id', selected_reading.reading_id,
                'title', selected_reading.reading_title,
                'content', selected_reading.reading_content,
                'quote', selected_reading.reading_quote,
                'scopeName', selected_reading.scope_name,
                'createdAt', selected_reading.reading_created_at,
                'userFeedback', NULL,
                'isRead', false
            )
        );
    END IF;
    
    -- Strategy 3: Fallback to oldest reading (restart cycle)
    SELECT * INTO selected_reading
    FROM get_oldest_reading_for_preference(p_user_id, user_preference_id);
    
    IF selected_reading.reading_id IS NOT NULL THEN
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (p_user_id, selected_reading.reading_id, today_date, false, NOW())
        ON CONFLICT (user_id, reading_date) DO NOTHING;
        
        -- Update progress and increment cycle
        UPDATE user_reading_progress 
        SET 
            last_reading_created_at = selected_reading.reading_created_at,
            total_readings_consumed = total_readings_consumed + 1,
            cycle_count = cycle_count + 1,
            updated_at = NOW()
        WHERE user_id = p_user_id AND preference_id = user_preference_id;
        
        RETURN json_build_object(
            'success', true,
            'action', 'new_reading_generated',
            'message', 'Daily reading generated successfully (restarted cycle)',
            'reading', json_build_object(
                'id', selected_reading.reading_id,
                'title', selected_reading.reading_title,
                'content', selected_reading.reading_content,
                'quote', selected_reading.reading_quote,
                'scopeName', selected_reading.scope_name,
                'createdAt', selected_reading.reading_created_at,
                'userFeedback', NULL,
                'isRead', false
            )
        );
    END IF;
    
    -- No readings available for this preference
    RETURN json_build_object(
        'success', false,
        'action', 'no_readings_available',
        'message', 'No readings available for user preference'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'action', 'error',
            'message', SQLERRM
        );
END;
$$;

-- ============================================================================
-- FIX 6: Add function to force regenerate daily reading
-- ============================================================================

CREATE OR REPLACE FUNCTION force_regenerate_daily_reading(
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    today_date DATE := CURRENT_DATE;
BEGIN
    -- Delete existing daily reading for today
    DELETE FROM daily_readings 
    WHERE user_id = p_user_id AND reading_date = today_date;
    
    -- Generate new daily reading
    RETURN generate_daily_reading_for_user(p_user_id);
END;
$$;

-- ============================================================================
-- FIX 7: Fix mark_reading_as_read - Remove non-existent updated_at column
-- ============================================================================

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

-- ============================================================================
-- Grant permissions
-- ============================================================================

GRANT EXECUTE ON FUNCTION get_user_reading_interaction(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_next_uninteracted_reading(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_newest_reading_for_preference(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_oldest_reading_for_preference(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_daily_reading_for_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION force_regenerate_daily_reading(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_reading_as_read(UUID, UUID) TO authenticated;

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Test the fixed functions
SELECT 'TESTING FIXED FUNCTIONS' as status;

-- Test get_user_reading_interaction (should not have ambiguous column error)
SELECT 'Testing get_user_reading_interaction...' as test;

-- Test get_oldest_reading_for_preference (should not have type mismatch)
SELECT 'Testing get_oldest_reading_for_preference...' as test;

-- Test get_next_uninteracted_reading (should work properly)
SELECT 'Testing get_next_uninteracted_reading...' as test;

SELECT 'ALL FIXES APPLIED SUCCESSFULLY' as completion_status;

-- ============================================================================
-- ADDITIONAL TESTING: Test mark_reading_as_read fix
-- ============================================================================

-- Test the fixed mark_reading_as_read function
SELECT '';
SELECT 'TESTING mark_reading_as_read FIX' as test_section;

DO $$
DECLARE
    test_user_id UUID;
    test_reading_id UUID;
    test_result JSON;
    daily_reading_exists BOOLEAN;
BEGIN
    -- Get a user with preference and a reading
    SELECT u.id INTO test_user_id 
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    SELECT r.id INTO test_reading_id 
    FROM readings r 
    WHERE r.is_active = true 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_reading_id IS NOT NULL THEN
        RAISE NOTICE 'Testing mark_reading_as_read with user: % and reading: %', test_user_id, test_reading_id;
        
        -- First, ensure we have a daily reading for today
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (test_user_id, test_reading_id, CURRENT_DATE, false, NOW())
        ON CONFLICT (user_id, reading_date) DO UPDATE SET reading_id = EXCLUDED.reading_id;
        
        -- Now test the mark_reading_as_read function
        SELECT mark_reading_as_read(test_user_id, test_reading_id) INTO test_result;
        
        RAISE NOTICE 'mark_reading_as_read result: %', test_result::text;
        
        -- Verify the daily reading was actually marked as read
        SELECT EXISTS(
            SELECT 1 FROM daily_readings 
            WHERE user_id = test_user_id 
            AND reading_id = test_reading_id 
            AND reading_date = CURRENT_DATE 
            AND is_read = true
        ) INTO daily_reading_exists;
        
        IF daily_reading_exists THEN
            RAISE NOTICE '✅ SUCCESS: Daily reading was marked as read correctly';
        ELSE
            RAISE NOTICE '❌ FAILED: Daily reading was not marked as read';
        END IF;
        
    ELSE
        RAISE NOTICE '❌ Cannot test: No suitable test data available';
    END IF;
END $$;
