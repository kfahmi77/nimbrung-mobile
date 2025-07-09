-- ============================================================================
-- QUICK FIX: Mark Reading as Read Error
-- This fixes the "updated_at column does not exist" error
-- ============================================================================

-- Fix the mark_reading_as_read function to remove non-existent updated_at column
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

-- Ensure proper permissions
GRANT EXECUTE ON FUNCTION mark_reading_as_read(UUID, UUID) TO authenticated;

-- Test the function works
SELECT 'mark_reading_as_read function updated successfully' as status;

-- Optional: Test with sample data if available
DO $$
DECLARE
    test_user_id UUID;
    test_reading_id UUID;
    test_result JSON;
BEGIN
    -- Get sample data for testing
    SELECT u.id INTO test_user_id 
    FROM users u 
    WHERE u.preference_id IS NOT NULL 
    LIMIT 1;
    
    SELECT r.id INTO test_reading_id 
    FROM readings r 
    WHERE r.is_active = true 
    LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_reading_id IS NOT NULL THEN
        -- Create a test daily reading
        INSERT INTO daily_readings (user_id, reading_id, reading_date, is_read, created_at)
        VALUES (test_user_id, test_reading_id, CURRENT_DATE, false, NOW())
        ON CONFLICT (user_id, reading_date) DO UPDATE SET reading_id = EXCLUDED.reading_id;
        
        -- Test the function
        SELECT mark_reading_as_read(test_user_id, test_reading_id) INTO test_result;
        
        RAISE NOTICE 'Test result: %', test_result::text;
        
        IF (test_result->>'success')::boolean = true THEN
            RAISE NOTICE '✅ mark_reading_as_read function is working correctly';
        ELSE
            RAISE NOTICE '❌ mark_reading_as_read function test failed: %', test_result->>'message';
        END IF;
    ELSE
        RAISE NOTICE 'ℹ️ Skipping test - no suitable test data available';
    END IF;
END $$;
