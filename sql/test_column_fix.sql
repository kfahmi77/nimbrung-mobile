-- Test script to verify the column ambiguity fix
-- Run this after applying the fix_column_ambiguity.sql script

-- ============================================================================
-- STEP 1: Get a real user ID from your database
-- ============================================================================

-- Find a user ID to test with
SELECT id, email FROM users LIMIT 5;

-- ============================================================================
-- STEP 2: Test each function individually
-- ============================================================================

-- Replace 'USER_ID_HERE' with an actual user ID from the query above

-- Test 1: Generate daily reading (should not return errors)
SELECT generate_daily_reading('USER_ID_HERE'::UUID);

-- Test 2: Get daily reading (should return reading data without ambiguity error)
SELECT * FROM get_daily_reading('USER_ID_HERE'::UUID);

-- Test 3: Check if daily reading was created
SELECT dr.id, dr.user_id, dr.reading_id, dr.reading_date, dr.is_read
FROM daily_readings dr 
WHERE dr.user_id = 'USER_ID_HERE'::UUID 
AND dr.reading_date = CURRENT_DATE;

-- Test 4: Get user preferences
SELECT get_user_preferences('USER_ID_HERE'::UUID);

-- ============================================================================
-- STEP 3: Test feedback and mark-as-read functions
-- ============================================================================

-- Get a reading ID to test with
SELECT r.id, r.title 
FROM daily_readings dr
JOIN readings r ON dr.reading_id = r.id
WHERE dr.user_id = 'USER_ID_HERE'::UUID 
AND dr.reading_date = CURRENT_DATE
LIMIT 1;

-- Test 5: Mark reading as read (replace READING_ID_HERE with actual reading ID)
SELECT mark_reading_as_read('USER_ID_HERE'::UUID, 'READING_ID_HERE'::UUID);

-- Test 6: Submit feedback (replace READING_ID_HERE with actual reading ID)
SELECT submit_reading_feedback('USER_ID_HERE'::UUID, 'READING_ID_HERE'::UUID, 'liked');

-- ============================================================================
-- STEP 4: Verify the results
-- ============================================================================

-- Check if reading was marked as read
SELECT dr.is_read, dr.reading_date
FROM daily_readings dr 
WHERE dr.user_id = 'USER_ID_HERE'::UUID 
AND dr.reading_date = CURRENT_DATE;

-- Check if feedback was recorded
SELECT rf.feedback_type, rf.created_at
FROM reading_feedbacks rf
WHERE rf.user_id = 'USER_ID_HERE'::UUID
LIMIT 5;

-- ============================================================================
-- SUCCESS INDICATORS
-- ============================================================================

/*
If the fix worked, you should see:

1. No "column reference 'reading_date' is ambiguous" errors
2. No "structure of query does not match function result type" errors
3. generate_daily_reading() completes without error
4. get_daily_reading() returns a row with all expected columns
5. mark_reading_as_read() returns JSON with success: true
6. submit_reading_feedback() returns JSON with success: true

If you still see errors, check:
- That all functions were dropped and recreated successfully
- That your database schema matches the expected structure
- That the user ID and reading ID you're testing with actually exist in the database
*/
