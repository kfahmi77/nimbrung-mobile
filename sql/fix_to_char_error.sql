-- ============================================================================
-- FIX FOR TO_CHAR ERROR IN BULK GENERATION FUNCTION
-- This fixes the "function to_char(time with time zone, unknown) does not exist" error
-- ============================================================================

-- Drop and recreate the function without TO_CHAR usage
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
    
    -- Count total users to process (process all users with preferences)
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
                
                -- Log individual user error for debugging
                INSERT INTO cron_job_logs (job_name, user_id, status, error_message, created_at)
                VALUES (
                    'daily_read_err', 
                    user_record.id, 
                    'error', 
                    format('User: %s, Error: %s', user_record.email, SQLERRM),
                    NOW()
                );
                
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
        'message', 'Daily reading generation completed successfully'
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

-- Test the function
SELECT 'Testing fixed bulk generation function...' as info;
SELECT generate_daily_readings_for_all_users() as result;
