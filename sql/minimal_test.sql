-- MINIMAL SETUP TEST - Run this to ensure basic functionality
-- This creates the absolute minimum data needed for testing

-- ============================================================================
-- STEP 1: Ensure we have basic data structure
-- ============================================================================

-- Create a test preference if none exists
INSERT INTO preferences (id, preferences_name) VALUES
('test-pref-001', 'Test Programming')
ON CONFLICT (id) DO NOTHING;

-- Create a test user if none exists with proper preference
INSERT INTO users (id, email, username, preference_id) VALUES
('test-user-001', 'test@example.com', 'testuser', 'test-pref-001')
ON CONFLICT (id) DO UPDATE SET preference_id = 'test-pref-001';

-- Create a test reading subject
INSERT INTO reading_subjects (id, name, description, preference_id, is_active) VALUES
('test-subject-001', 'Test Subject', 'A test reading subject', 'test-pref-001', true)
ON CONFLICT (id) DO NOTHING;

-- Create a test daily reading
INSERT INTO daily_readings (id, subject_id, day_sequence, title, content, key_insight) VALUES
('test-reading-001', 'test-subject-001', 1, 'Test Reading', 'This is a test reading content.', 'Test insight')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 2: Test the function with known data
-- ============================================================================

-- Test the function
SELECT 'Testing with test user...' as status;
SELECT * FROM get_today_reading('test-user-001'::uuid);

-- ============================================================================
-- STEP 3: Verify data exists
-- ============================================================================

-- Check our test data
SELECT 'Test user:' as info, id, email, preference_id FROM users WHERE id = 'test-user-001';
SELECT 'Test subject:' as info, id, name, preference_id FROM reading_subjects WHERE id = 'test-subject-001';
SELECT 'Test reading:' as info, id, title, day_sequence FROM daily_readings WHERE id = 'test-reading-001';

-- ============================================================================
-- If this works, your RPC function is fine and the issue is data-related
-- If this fails, there's an issue with the function itself
-- ============================================================================
