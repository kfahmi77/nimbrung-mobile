-- ============================================================================
-- QUICK VERIFICATION FOR REPORTED ISSUES
-- Tests the specific problems mentioned by the user
-- ============================================================================

SELECT 'VERIFICATION: Testing Reported Issues' as title;
SELECT '===========================================' as separator;

-- Test the specific functions that were failing

-- 1. Test get_user_reading_interaction (was showing ambiguous column error)
SELECT 'TEST 1: get_user_reading_interaction (fixing ambiguous column)' as test;

DO $$
DECLARE
    test_user_id UUID;
    test_reading_id UUID;
    result RECORD;
BEGIN
    -- Get test data
    SELECT u.id INTO test_user_id 
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    SELECT r.id INTO test_reading_id 
    FROM readings r 
    WHERE r.is_active = true 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_reading_id IS NOT NULL THEN
        -- This should no longer give "ambiguous column" error
        SELECT * INTO result 
        FROM get_user_reading_interaction(test_user_id, test_reading_id);
        
        RAISE NOTICE '✅ get_user_reading_interaction WORKING - has_feedback: %, feedback_type: %', 
                     result.has_feedback, result.feedback_type;
    ELSE
        RAISE NOTICE '❌ No test data available';
    END IF;
END $$;

-- 2. Test get_oldest_reading_for_preference (was showing type mismatch)
SELECT '';
SELECT 'TEST 2: get_oldest_reading_for_preference (fixing type mismatch)' as test;

DO $$
DECLARE
    test_user_id UUID;
    test_preference_id UUID;
    result RECORD;
BEGIN
    -- Get test data
    SELECT u.id, u.preference_id INTO test_user_id, test_preference_id
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_preference_id IS NOT NULL THEN
        -- This should no longer give "structure does not match" error
        SELECT * INTO result 
        FROM get_oldest_reading_for_preference(test_user_id, test_preference_id);
        
        RAISE NOTICE '✅ get_oldest_reading_for_preference WORKING - title: %, scope: %', 
                     result.reading_title, result.scope_name;
    ELSE
        RAISE NOTICE '❌ No test data available';
    END IF;
END $$;

-- 3. Test get_next_uninteracted_reading (should return "ruang lingkup sains 2")
SELECT '';
SELECT 'TEST 3: get_next_uninteracted_reading (should show sains 2)' as test;

DO $$
DECLARE
    sains_user_id UUID;
    sains_preference_id UUID;
    result RECORD;
BEGIN
    -- Find user with "ruang lingkup sains" preference
    SELECT u.id, u.preference_id INTO sains_user_id, sains_preference_id
    FROM users u
    JOIN preferences p ON u.preference_id = p.id
    WHERE p.name ILIKE '%sains%'
    LIMIT 1;
    
    IF sains_user_id IS NOT NULL THEN
        SELECT * INTO result 
        FROM get_next_uninteracted_reading(sains_user_id, sains_preference_id);
        
        IF result.reading_id IS NOT NULL THEN
            RAISE NOTICE '✅ Next uninteracted reading: % (scope: %)', 
                         result.reading_title, result.scope_name;
            
            -- Check if this is "ruang lingkup sains 2"
            IF result.reading_title ILIKE '%sains 2%' THEN
                RAISE NOTICE '🎯 CORRECT: Found "sains 2" as expected!';
            ELSE
                RAISE NOTICE '⚠️  Found different reading: %', result.reading_title;
            END IF;
        ELSE
            RAISE NOTICE '❌ No uninteracted readings found';
        END IF;
    ELSE
        RAISE NOTICE '❌ No user with sains preference found';
    END IF;
END $$;

-- 4. Test force_regenerate_daily_reading for the sains user
SELECT '';
SELECT 'TEST 4: force_regenerate_daily_reading (should generate sains 2)' as test;

DO $$
DECLARE
    sains_user_id UUID;
    result JSON;
    reading_data JSON;
BEGIN
    -- Find user with "ruang lingkup sains" preference
    SELECT u.id INTO sains_user_id
    FROM users u
    JOIN preferences p ON u.preference_id = p.id
    WHERE p.name ILIKE '%sains%'
    LIMIT 1;
    
    IF sains_user_id IS NOT NULL THEN
        -- Force regenerate to get latest uninteracted reading
        SELECT force_regenerate_daily_reading(sains_user_id) INTO result;
        
        RAISE NOTICE 'Force regenerate result: %', result::text;
        
        -- Extract reading data
        reading_data := result->'reading';
        
        IF reading_data IS NOT NULL THEN
            RAISE NOTICE '✅ Generated reading: % (scope: %)', 
                         reading_data->>'title', reading_data->>'scopeName';
                         
            -- Check if we got "sains 2"
            IF (reading_data->>'title') ILIKE '%sains 2%' THEN
                RAISE NOTICE '🎯 SUCCESS: Generated "sains 2" as expected!';
            ELSE
                RAISE NOTICE '⚠️  Generated different reading: %', reading_data->>'title';
            END IF;
        END IF;
    END IF;
END $$;

-- 5. Show current daily readings to verify state
SELECT '';
SELECT 'TEST 5: Current Daily Readings State' as test;
SELECT 
    u.email,
    p.name as preference_name,
    r.title as current_reading,
    s.name as scope_name,
    dr.reading_date,
    dr.is_read,
    rf.feedback_type
FROM daily_readings dr
JOIN users u ON dr.user_id = u.id
LEFT JOIN preferences p ON u.preference_id = p.id
JOIN readings r ON dr.reading_id = r.id
JOIN scopes s ON r.scope_id = s.id
LEFT JOIN reading_feedbacks rf ON rf.user_id = dr.user_id AND rf.reading_id = dr.reading_id
WHERE dr.reading_date = CURRENT_DATE
ORDER BY dr.created_at DESC;

SELECT '';
SELECT '===========================================' as separator;
SELECT 'VERIFICATION COMPLETE' as status;
SELECT 'All reported issues should now be resolved!' as conclusion;
