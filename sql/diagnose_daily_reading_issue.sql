-- ============================================================================
-- DIAGNOSTIC SCRIPT FOR DAILY READING GENERATION ISSUE
-- This script investigates why daily readings are not being generated
-- ============================================================================

-- Check if functions exist
SELECT 'FUNCTION DEPLOYMENT STATUS:' as section;
SELECT 
    proname as function_name,
    'EXISTS' as status
FROM pg_proc 
WHERE proname IN (
    'get_user_daily_reading',
    'submit_reading_feedback', 
    'mark_reading_as_read',
    'generate_daily_reading_for_user',
    'generate_daily_readings_for_all_users',
    'get_user_reading_interaction',
    'get_available_readings_for_user'
)
ORDER BY proname;

-- Check basic data counts
SELECT 'DATA COUNTS:' as section;
SELECT 
    'users' as table_name,
    COUNT(*) as count
FROM users
UNION ALL
SELECT 
    'users_with_preferences' as table_name,
    COUNT(*) as count
FROM users 
WHERE preference_id IS NOT NULL
UNION ALL
SELECT 
    'preferences' as table_name,
    COUNT(*) as count
FROM preferences
UNION ALL
SELECT 
    'scopes' as table_name,
    COUNT(*) as count
FROM scopes
UNION ALL
SELECT 
    'readings' as table_name,
    COUNT(*) as count
FROM readings
UNION ALL
SELECT 
    'active_readings' as table_name,
    COUNT(*) as count
FROM readings 
WHERE is_active = true
UNION ALL
SELECT 
    'daily_readings' as table_name,
    COUNT(*) as count
FROM daily_readings
UNION ALL
SELECT 
    'todays_daily_readings' as table_name,
    COUNT(*) as count
FROM daily_readings 
WHERE reading_date = CURRENT_DATE;

-- Check sample data structure
SELECT 'SAMPLE DATA STRUCTURE:' as section;

-- Sample users
SELECT 'Sample users with preferences:' as info;
SELECT 
    u.id,
    u.email,
    u.preference_id,
    p.preferences_name
FROM users u
LEFT JOIN preferences p ON u.preference_id = p.id
WHERE u.preference_id IS NOT NULL
LIMIT 3;

-- Sample scopes per preference
SELECT 'Scopes per preference:' as info;
SELECT 
    p.preferences_name,
    s.id as scope_id,
    s.name as scope_name,
    COUNT(r.id) as reading_count
FROM preferences p
LEFT JOIN scopes s ON s.preference_id = p.id
LEFT JOIN readings r ON r.scope_id = s.id AND r.is_active = true
GROUP BY p.id, p.preferences_name, s.id, s.name
ORDER BY p.preferences_name, s.name;

-- Sample readings per scope
SELECT 'Readings per scope:' as info;
SELECT 
    s.name as scope_name,
    COUNT(r.id) as reading_count,
    COUNT(CASE WHEN r.is_active THEN 1 END) as active_reading_count
FROM scopes s
LEFT JOIN readings r ON s.id = r.scope_id
GROUP BY s.id, s.name
ORDER BY reading_count DESC;

-- Check cron job logs
SELECT 'RECENT CRON JOB LOGS:' as section;
SELECT 
    job_name,
    status,
    message,
    users_processed,
    errors_count,
    execution_time,
    created_at
FROM cron_job_logs 
ORDER BY created_at DESC 
LIMIT 10;

-- Test individual user generation
SELECT 'INDIVIDUAL USER TEST:' as section;

DO $$
DECLARE
    test_user_id UUID;
    test_preference_id UUID;
    test_scope_id UUID;
    available_readings_count INTEGER;
    generation_result JSON;
BEGIN
    -- Get a test user with preferences
    SELECT u.id, u.preference_id
    INTO test_user_id, test_preference_id
    FROM users u
    WHERE u.preference_id IS NOT NULL
    LIMIT 1;
    
    IF test_user_id IS NOT NULL THEN
        RAISE NOTICE 'Testing with user: %, preference: %', 
            test_user_id, test_preference_id;
            
        -- Get a scope for this preference
        SELECT s.id INTO test_scope_id
        FROM scopes s
        WHERE s.preference_id = test_preference_id
        LIMIT 1;
        
        RAISE NOTICE 'Found scope: %', test_scope_id;
            
        -- Check available readings for this user
        SELECT COUNT(*)
        INTO available_readings_count
        FROM readings r
        JOIN scopes s ON r.scope_id = s.id
        WHERE s.preference_id = test_preference_id
        AND r.is_active = true
        AND NOT EXISTS (
            SELECT 1 FROM daily_readings dr
            WHERE dr.user_id = test_user_id
            AND dr.reading_id = r.id
        )
        AND NOT EXISTS (
            SELECT 1 FROM reading_feedbacks rf
            WHERE rf.user_id = test_user_id
            AND rf.reading_id = r.id
        );
        
        RAISE NOTICE 'Available readings for user: %', available_readings_count;
        
        -- Try to generate a daily reading
        BEGIN
            SELECT generate_daily_reading_for_user(test_user_id) INTO generation_result;
            RAISE NOTICE 'Generation result: %', generation_result;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error during generation: %', SQLERRM;
        END;
        
    ELSE
        RAISE NOTICE 'No users with preferences found for testing';
    END IF;
END
$$;

SELECT 'DIAGNOSTIC COMPLETE' as final_status;
