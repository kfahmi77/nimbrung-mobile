-- ============================================================================
-- FINAL DEPLOYMENT SCRIPT FOR DAILY READING SYSTEM
-- This script deploys the complete daily reading feature with all functions
-- ============================================================================

BEGIN;

-- ============================================================================
-- STEP 1: Create unique indexes to prevent constraint violations
-- ============================================================================

-- Unique constraint on daily_readings to prevent duplicate readings per day
CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_readings_user_date 
ON daily_readings (user_id, reading_date);

-- Unique constraint on reading_feedbacks to prevent duplicate feedback
CREATE UNIQUE INDEX IF NOT EXISTS idx_reading_feedbacks_user_reading 
ON reading_feedbacks (user_id, reading_id);

-- Unique constraint on user_reading_progress
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_reading_progress_user_preference 
ON user_reading_progress (user_id, preference_id);

-- ============================================================================
-- STEP 2: Helper Functions
-- ============================================================================

-- Function to get user's reading history for a specific reading
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
            (SELECT feedback_type FROM reading_feedbacks 
             WHERE user_id = p_user_id AND reading_id = p_reading_id 
             LIMIT 1), 
            NULL
        ) as feedback_type,
        COALESCE(
            (SELECT is_read FROM daily_readings 
             WHERE user_id = p_user_id AND reading_id = p_reading_id 
             LIMIT 1), 
            false
        ) as is_read;
END;
$$;

-- Function to get next uninteracted reading for user
CREATE OR REPLACE FUNCTION get_next_uninteracted_reading(
    p_user_id UUID,
    p_preference_id UUID
)
RETURNS TABLE (
    reading_id UUID,
    reading_title CHARACTER VARYING,
    reading_content TEXT,
    reading_quote TEXT,
    scope_name CHARACTER VARYING,
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
        r.title,
        r.content,
        r.quote,
        s.name,
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

-- Function to get newest reading for user's preference
CREATE OR REPLACE FUNCTION get_newest_reading_for_preference(
    p_user_id UUID,
    p_preference_id UUID
)
RETURNS TABLE (
    reading_id UUID,
    reading_title CHARACTER VARYING,
    reading_content TEXT,
    reading_quote TEXT,
    scope_name CHARACTER VARYING,
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
        r.title,
        r.content,
        r.quote,
        s.name,
        r.created_at
    FROM readings r
    JOIN scopes s ON r.scope_id = s.id
    WHERE s.preference_id = p_preference_id
    AND r.is_active = true
    ORDER BY r.created_at DESC
    LIMIT 1;
END;
$$;

-- Function to get oldest reading for preference (restart logic)
CREATE OR REPLACE FUNCTION get_oldest_reading_for_preference(
    p_user_id UUID,
    p_preference_id UUID
)
RETURNS TABLE (
    reading_id UUID,
    reading_title CHARACTER VARYING,
    reading_content TEXT,
    reading_quote TEXT,
    scope_name CHARACTER VARYING,
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
        r.title,
        r.content,
        r.quote,
        s.name,
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
-- STEP 3: Main Daily Reading Generation Function
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
    
    IF existing_daily_reading.id IS NOT NULL THEN
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
            'action', 'reading_generated',
            'strategy', 'uninteracted_reading',
            'message', 'Generated daily reading from uninteracted readings',
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
    
    -- Strategy 2: Check if there's a newer reading than user's last consumed
    SELECT * INTO newest_reading
    FROM get_newest_reading_for_preference(p_user_id, user_preference_id);
    
    IF newest_reading.reading_id IS NOT NULL AND 
       newest_reading.reading_created_at > progress_record.last_reading_created_at THEN
        -- There's a newer reading available
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (p_user_id, newest_reading.reading_id, today_date, false, NOW())
        ON CONFLICT (user_id, reading_date) DO NOTHING;
        
        -- Update progress
        UPDATE user_reading_progress 
        SET 
            last_reading_created_at = newest_reading.reading_created_at,
            total_readings_consumed = total_readings_consumed + 1,
            updated_at = NOW()
        WHERE user_id = p_user_id AND preference_id = user_preference_id;
        
        RETURN json_build_object(
            'success', true,
            'action', 'reading_generated',
            'strategy', 'newest_reading',
            'message', 'Generated daily reading from newest available reading',
            'reading', json_build_object(
                'id', newest_reading.reading_id,
                'title', newest_reading.reading_title,
                'content', newest_reading.reading_content,
                'quote', newest_reading.reading_quote,
                'scopeName', newest_reading.scope_name,
                'createdAt', newest_reading.reading_created_at,
                'userFeedback', NULL,
                'isRead', false
            )
        );
    END IF;
    
    -- Strategy 3: Restart from beginning (oldest reading)
    SELECT * INTO selected_reading
    FROM get_oldest_reading_for_preference(p_user_id, user_preference_id);
    
    IF selected_reading.reading_id IS NOT NULL THEN
        -- Restart from beginning
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (p_user_id, selected_reading.reading_id, today_date, false, NOW())
        ON CONFLICT (user_id, reading_date) DO NOTHING;
        
        -- Update progress with cycle restart
        UPDATE user_reading_progress 
        SET 
            last_reading_created_at = selected_reading.reading_created_at,
            total_readings_consumed = total_readings_consumed + 1,
            cycle_count = cycle_count + 1,
            updated_at = NOW()
        WHERE user_id = p_user_id AND preference_id = user_preference_id;
        
        RETURN json_build_object(
            'success', true,
            'action', 'reading_generated',
            'strategy', 'cycle_restart',
            'message', 'Generated daily reading by restarting cycle from beginning',
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
-- STEP 4: RPC Functions for Frontend
-- ============================================================================

-- RPC: Get daily reading for user
CREATE OR REPLACE FUNCTION get_user_daily_reading(
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    daily_reading_record RECORD;
    today_date DATE := CURRENT_DATE;
BEGIN
    -- Get today's daily reading for user
    SELECT 
        dr.id as daily_reading_id,
        dr.reading_date,
        dr.is_read,
        r.id as reading_id,
        r.title,
        r.content,
        r.quote,
        s.name as scope_name,
        r.created_at as reading_created_at,
        COALESCE(rf.feedback_type, NULL) as user_feedback
    INTO daily_reading_record
    FROM daily_readings dr
    JOIN readings r ON dr.reading_id = r.id
    JOIN scopes s ON r.scope_id = s.id
    LEFT JOIN reading_feedbacks rf ON rf.reading_id = r.id AND rf.user_id = p_user_id
    WHERE dr.user_id = p_user_id 
    AND dr.reading_date = today_date
    ORDER BY dr.created_at DESC
    LIMIT 1;
    
    IF daily_reading_record.daily_reading_id IS NULL THEN
        -- No daily reading for today, try to generate one
        RETURN generate_daily_reading_for_user(p_user_id);
    END IF;
    
    -- Return existing daily reading
    RETURN json_build_object(
        'success', true,
        'action', 'existing_reading',
        'message', 'Daily reading found',
        'reading', json_build_object(
            'id', daily_reading_record.reading_id,
            'title', daily_reading_record.title,
            'content', daily_reading_record.content,
            'quote', daily_reading_record.quote,
            'scopeName', daily_reading_record.scope_name,
            'createdAt', daily_reading_record.reading_created_at,
            'userFeedback', daily_reading_record.user_feedback,
            'isRead', daily_reading_record.is_read
        )
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

-- RPC: Submit reading feedback
CREATE OR REPLACE FUNCTION submit_reading_feedback(
    p_user_id UUID,
    p_reading_id UUID,
    p_feedback_type TEXT
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
    INSERT INTO reading_feedbacks (user_id, reading_id, feedback_type, created_at, updated_at)
    VALUES (p_user_id, p_reading_id, p_feedback_type, NOW(), NOW())
    ON CONFLICT (user_id, reading_id) 
    DO UPDATE SET 
        feedback_type = EXCLUDED.feedback_type,
        updated_at = NOW();
    
    RETURN json_build_object(
        'success', true,
        'message', 'Feedback submitted successfully'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', SQLERRM
        );
END;
$$;

-- RPC: Mark reading as read
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
    UPDATE daily_readings 
    SET 
        is_read = true,
        updated_at = NOW()
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

-- Bulk generation for cron jobs
CREATE OR REPLACE FUNCTION generate_daily_readings_for_all_users()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
    user_record RECORD;
    generated_count INTEGER := 0;
    error_count INTEGER := 0;
    skipped_count INTEGER := 0;
    existing_count INTEGER := 0;
    start_time TIMESTAMP := NOW();
    job_log_id UUID;
    total_users INTEGER := 0;
    generation_result JSON;
    action_taken TEXT;
BEGIN
    -- Create initial log entry
    INSERT INTO cron_job_logs (job_name, status, message, created_at)
    VALUES (
        'daily_reading_gen', 
        'running', 
        'Starting daily reading generation for all users',
        start_time
    )
    RETURNING id INTO job_log_id;
    
    -- Count total users to process (exclude users created today to avoid new users)
    SELECT COUNT(*) INTO total_users 
    FROM users 
    WHERE id IS NOT NULL 
    AND preference_id IS NOT NULL;
    
    -- Loop through all users with preferences
    FOR user_record IN 
        SELECT id, email, preference_id, created_at
        FROM users 
        WHERE id IS NOT NULL
        AND preference_id IS NOT NULL
        ORDER BY created_at ASC
    LOOP
        BEGIN
            -- Generate daily reading for this user
            SELECT generate_daily_reading_for_user(user_record.id) INTO generation_result;
            
            -- Parse the result and count appropriately
            action_taken := generation_result->>'action';
            
            CASE action_taken
                WHEN 'reading_generated' THEN
                    generated_count := generated_count + 1;
                WHEN 'existing_reading' THEN
                    existing_count := existing_count + 1;
                WHEN 'skipped_no_preference' THEN
                    skipped_count := skipped_count + 1;
                WHEN 'no_readings_available' THEN
                    skipped_count := skipped_count + 1;
                WHEN 'error' THEN
                    error_count := error_count + 1;
                ELSE
                    error_count := error_count + 1;
            END CASE;
            
        EXCEPTION
            WHEN OTHERS THEN
                error_count := error_count + 1;
                CONTINUE;
        END;
    END LOOP;
    
    -- Update final log entry
    UPDATE cron_job_logs 
    SET 
        status = CASE WHEN error_count = 0 THEN 'completed' ELSE 'completed_w_errors' END,
        message = format('Daily reading generation completed. Total: %s, Generated: %s, Existing: %s, Skipped: %s, Errors: %s', 
                        total_users, generated_count, existing_count, skipped_count, error_count),
        users_processed = generated_count + existing_count + skipped_count + error_count,
        errors_count = error_count,
        execution_time = EXTRACT(EPOCH FROM (NOW() - start_time))
    WHERE id = job_log_id;
    
    -- Return summary
    RETURN json_build_object(
        'success', true,
        'job_log_id', job_log_id,
        'total_users', total_users,
        'generated_count', generated_count,
        'existing_count', existing_count,
        'skipped_count', skipped_count,
        'error_count', error_count,
        'execution_time_seconds', EXTRACT(EPOCH FROM (NOW() - start_time)),
        'message', 'Daily reading generation completed'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Handle any unexpected errors
        UPDATE cron_job_logs 
        SET 
            status = 'error',
            error_message = SQLERRM,
            execution_time = EXTRACT(EPOCH FROM (NOW() - start_time))
        WHERE id = job_log_id;
        
        RETURN json_build_object(
            'success', false,
            'job_log_id', job_log_id,
            'error_message', SQLERRM,
            'execution_time_seconds', EXTRACT(EPOCH FROM (NOW() - start_time))
        );
END;
$$;

-- ============================================================================
-- STEP 5: Grant Permissions
-- ============================================================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION get_user_reading_interaction(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_next_uninteracted_reading(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_newest_reading_for_preference(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_oldest_reading_for_preference(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION generate_daily_reading_for_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_daily_reading(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION submit_reading_feedback(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION mark_reading_as_read(UUID, UUID) TO authenticated;

-- Grant execute permissions to service_role for cron jobs
GRANT EXECUTE ON FUNCTION generate_daily_readings_for_all_users() TO service_role;

COMMIT;

-- ============================================================================
-- STEP 6: Test the System
-- ============================================================================

SELECT 'Daily reading system deployment completed successfully!' as status;

-- Test bulk generation
SELECT 'Testing bulk generation...' as test;
SELECT generate_daily_readings_for_all_users() as result;
