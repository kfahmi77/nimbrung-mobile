-- Test script to verify foreign key constraint fix for feedback submission
-- This script tests the fix for the "reading_feedbacks_reading_id_fkey" constraint violation

-- ============================================================================
-- STEP 1: Get real data from your database for testing
-- ============================================================================

-- Get a user ID to test with
SELECT 'User IDs available for testing:' as info;
SELECT id, email FROM users LIMIT 3;

-- Get some reading data
SELECT 'Readings available:' as info;
SELECT id, title FROM readings WHERE is_active = true LIMIT 3;

-- ============================================================================
-- STEP 2: Test the fixed daily reading flow
-- ============================================================================

-- Replace USER_ID_HERE with an actual user ID from the first query
DO $$
DECLARE
    test_user_id UUID := 'USER_ID_HERE'::UUID;  -- Replace with actual user ID
    daily_reading RECORD;
    feedback_result JSON;
    mark_result JSON;
BEGIN
    -- Test 1: Generate daily reading
    RAISE NOTICE 'Test 1: Generating daily reading for user %', test_user_id;
    PERFORM generate_daily_reading(test_user_id);
    RAISE NOTICE 'Daily reading generation completed';

    -- Test 2: Get daily reading and check the ID returned
    RAISE NOTICE 'Test 2: Getting daily reading';
    SELECT * INTO daily_reading FROM get_daily_reading(test_user_id);
    
    IF daily_reading.id IS NOT NULL THEN
        RAISE NOTICE 'Daily reading found - ID: %, Title: %', daily_reading.id, daily_reading.title;
        
        -- Test 3: Verify this ID exists in readings table (should pass now)
        IF EXISTS (SELECT 1 FROM readings WHERE id = daily_reading.id::UUID) THEN
            RAISE NOTICE 'SUCCESS: Reading ID % exists in readings table', daily_reading.id;
            
            -- Test 4: Submit feedback (should work now)
            RAISE NOTICE 'Test 4: Submitting feedback for reading %', daily_reading.id;
            SELECT submit_reading_feedback(test_user_id, daily_reading.id::UUID, 'up') INTO feedback_result;
            RAISE NOTICE 'Feedback result: %', feedback_result;
            
            -- Test 5: Mark as read (should work)
            RAISE NOTICE 'Test 5: Marking reading as read';
            SELECT mark_reading_as_read(test_user_id, daily_reading.id::UUID) INTO mark_result;
            RAISE NOTICE 'Mark as read result: %', mark_result;
            
        ELSE
            RAISE WARNING 'PROBLEM: Reading ID % does NOT exist in readings table', daily_reading.id;
        END IF;
    ELSE
        RAISE WARNING 'No daily reading found for user %', test_user_id;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error during test: %', SQLERRM;
END $$;

-- ============================================================================
-- STEP 3: Manual verification queries
-- ============================================================================

-- Check what IDs are being returned by get_daily_reading
SELECT 'Current daily reading IDs and corresponding reading IDs:' as info;
SELECT 
    dr.id as daily_reading_id,
    dr.reading_id as actual_reading_id,
    r.id as readings_table_id,
    r.title
FROM daily_readings dr
JOIN readings r ON dr.reading_id = r.id
WHERE dr.reading_date = CURRENT_DATE
LIMIT 5;

-- Verify foreign key constraint
SELECT 'Foreign key constraint check:' as info;
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint 
WHERE conname LIKE '%reading_feedbacks%' 
AND contype = 'f';

-- ============================================================================
-- STEP 4: Test feedback submission with known good data
-- ============================================================================

-- Get a known reading ID that definitely exists
DO $$
DECLARE
    test_user_id UUID;
    test_reading_id UUID;
    feedback_result JSON;
BEGIN
    -- Get first available user
    SELECT id INTO test_user_id FROM users LIMIT 1;
    
    -- Get first available reading
    SELECT id INTO test_reading_id FROM readings WHERE is_active = true LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_reading_id IS NOT NULL THEN
        RAISE NOTICE 'Testing feedback with user % and reading %', test_user_id, test_reading_id;
        
        -- Test feedback submission
        SELECT submit_reading_feedback(test_user_id, test_reading_id, 'up') INTO feedback_result;
        RAISE NOTICE 'Direct feedback test result: %', feedback_result;
        
        -- Verify feedback was stored
        IF EXISTS (
            SELECT 1 FROM reading_feedbacks 
            WHERE user_id = test_user_id AND reading_id = test_reading_id
        ) THEN
            RAISE NOTICE 'SUCCESS: Feedback was stored successfully';
        ELSE
            RAISE WARNING 'WARNING: Feedback was not stored';
        END IF;
    ELSE
        RAISE WARNING 'Could not find test user or reading';
    END IF;
END $$;

-- ============================================================================
-- EXPECTED RESULTS
-- ============================================================================

/*
If the fix is working correctly, you should see:

1. "Daily reading generation completed" 
2. "Daily reading found - ID: [some-uuid], Title: [some-title]"
3. "SUCCESS: Reading ID [uuid] exists in readings table"
4. "Feedback result: {"success": true, "message": "Feedback submitted successfully"}"
5. "Mark as read result: {"success": true, "message": "Reading marked as read"}"
6. "SUCCESS: Feedback was stored successfully"

If you see any of these errors, the fix needs more work:
- "reading_feedbacks_reading_id_fkey constraint violation"
- "Reading ID does NOT exist in readings table"
- Feedback result with success: false

The key fix is that get_daily_reading() now returns r.id (readings.id) 
instead of dr.id (daily_readings.id), so the Flutter app gets the correct
ID to use for feedback submission.
*/
