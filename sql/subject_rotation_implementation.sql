-- SUBJECT ROTATION IMPLEMENTATION
-- This implements automatic subject rotation so users read different subjects on different days
-- Day 1 → Subject A, Day 2 → Subject B, Day 3 → Subject C, Day 4 → Subject A (day 2), etc.

-- ============================================================================
-- STEP 1: Drop and recreate rotation-based functions
-- ============================================================================

-- Drop existing functions that we'll replace
DROP FUNCTION IF EXISTS get_today_reading(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_today_readings(UUID);
DROP FUNCTION IF EXISTS get_rotated_reading(UUID);

-- ============================================================================
-- STEP 2: Create new rotation-based reading function
-- ============================================================================

-- Main function: Get today's reading with subject rotation
CREATE OR REPLACE FUNCTION get_today_reading(p_user_id UUID, target_day INTEGER DEFAULT NULL)
RETURNS TABLE (
  reading_id UUID,
  subject_id UUID,
  subject_name TEXT,
  day_sequence INTEGER,
  title TEXT,
  content TEXT,
  key_insight TEXT,
  tomorrow_hint TEXT,
  read_time_minutes INTEGER,
  is_completed BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  subject_ids UUID[];
  subject_names TEXT[];
  subject_count INT;
  total_days_read INT := 0;
  current_subject_index INT;
  selected_subject_id UUID;
  selected_subject_name TEXT;
  subject_day_sequence INT;
BEGIN
  -- Get all active subjects for this user (ordered consistently)
  SELECT 
    ARRAY_AGG(rs.id ORDER BY rs.created_at, rs.name),
    ARRAY_AGG(rs.name::TEXT ORDER BY rs.created_at, rs.name)
  INTO subject_ids, subject_names
  FROM reading_subjects rs
  JOIN users u ON u.preference_id = rs.preference_id
  WHERE u.id = p_user_id AND rs.is_active = true;

  -- Check if we have any subjects
  subject_count := array_length(subject_ids, 1);
  IF subject_count IS NULL OR subject_count = 0 THEN
    RAISE NOTICE 'No active subjects found for user %', p_user_id;
    RETURN;
  END IF;

  -- Calculate total days read across all subjects
  -- If target_day is specified, use it; otherwise calculate from progress
  IF target_day IS NOT NULL THEN
    total_days_read := target_day - 1; -- Convert to 0-indexed
  ELSE
    -- Sum up total completed readings across all subjects for this user
    SELECT COALESCE(SUM(urp.total_completed), 0)
    INTO total_days_read
    FROM user_reading_progress urp
    WHERE urp.user_id = p_user_id
      AND urp.subject_id = ANY(subject_ids);
  END IF;

  -- Calculate which subject should be read today (rotation)
  current_subject_index := total_days_read % subject_count;
  selected_subject_id := subject_ids[current_subject_index + 1]; -- PostgreSQL arrays are 1-indexed
  selected_subject_name := subject_names[current_subject_index + 1];

  -- Calculate which day sequence for this specific subject
  -- subject_day_sequence = (total_days_read / subject_count) + 1
  subject_day_sequence := (total_days_read / subject_count) + 1;

  RAISE NOTICE 'User: %, Total days: %, Subject count: %, Current index: %, Selected subject: %, Day sequence: %', 
    p_user_id, total_days_read, subject_count, current_subject_index, selected_subject_name, subject_day_sequence;

  -- Get the reading for the selected subject and day sequence
  RETURN QUERY
  SELECT 
    dr.id as reading_id,
    dr.subject_id,
    selected_subject_name,
    dr.day_sequence,
    dr.title::TEXT,
    dr.content::TEXT,
    dr.key_insight::TEXT,
    dr.tomorrow_hint::TEXT,
    dr.read_time_minutes,
    COALESCE((rc.id IS NOT NULL), false) as is_completed
  FROM daily_readings dr
  LEFT JOIN reading_completions rc ON rc.user_id = p_user_id AND rc.reading_id = dr.id
  WHERE dr.subject_id = selected_subject_id
    AND dr.day_sequence = subject_day_sequence
  LIMIT 1;
END;
$$;

-- ============================================================================
-- STEP 3: Create multiple readings function for home page display
-- ============================================================================

-- Function to get current reading for ALL subjects (for home page)
CREATE OR REPLACE FUNCTION get_today_readings(p_user_id UUID)
RETURNS TABLE (
  reading_id UUID,
  subject_id UUID,
  subject_name TEXT,
  day_sequence INTEGER,
  title TEXT,
  content TEXT,
  key_insight TEXT,
  tomorrow_hint TEXT,
  read_time_minutes INTEGER,
  is_completed BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  subject_record RECORD;
  subject_progress INT;
BEGIN
  -- For each subject, get the current reading based on user's progress in that subject
  FOR subject_record IN 
    SELECT rs.id, rs.name::TEXT as name
    FROM reading_subjects rs
    JOIN users u ON u.preference_id = rs.preference_id
    WHERE u.id = p_user_id AND rs.is_active = true
    ORDER BY rs.created_at, rs.name
  LOOP
    -- Get current progress for this specific subject
    SELECT COALESCE(urp.current_day, 1)
    INTO subject_progress
    FROM user_reading_progress urp
    WHERE urp.user_id = p_user_id AND urp.subject_id = subject_record.id;

    -- Return current reading for this subject
    RETURN QUERY
    SELECT 
      dr.id as reading_id,
      dr.subject_id,
      subject_record.name,
      dr.day_sequence,
      dr.title::TEXT,
      dr.content::TEXT,
      dr.key_insight::TEXT,
      dr.tomorrow_hint::TEXT,
      dr.read_time_minutes,
      COALESCE((rc.id IS NOT NULL), false) as is_completed
    FROM daily_readings dr
    LEFT JOIN reading_completions rc ON rc.user_id = p_user_id AND rc.reading_id = dr.id
    WHERE dr.subject_id = subject_record.id
      AND dr.day_sequence = COALESCE(subject_progress, 1)
    LIMIT 1;
  END LOOP;
END;
$$;

-- ============================================================================
-- STEP 4: Create helper function to get rotation schedule
-- ============================================================================

-- Function to see the rotation schedule for upcoming days
CREATE OR REPLACE FUNCTION get_rotation_schedule(p_user_id UUID, days_ahead INTEGER DEFAULT 7)
RETURNS TABLE (
  day_number INTEGER,
  subject_id UUID,
  subject_name TEXT,
  subject_day_sequence INTEGER,
  reading_title TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  subject_ids UUID[];
  subject_names TEXT[];
  subject_count INT;
  total_days_read INT;
  i INT;
  current_subject_index INT;
  selected_subject_id UUID;
  selected_subject_name TEXT;
  subject_day_sequence INT;
  reading_title_val TEXT;
BEGIN
  -- Get all active subjects for this user
  SELECT 
    ARRAY_AGG(rs.id ORDER BY rs.created_at, rs.name),
    ARRAY_AGG(rs.name::TEXT ORDER BY rs.created_at, rs.name)
  INTO subject_ids, subject_names
  FROM reading_subjects rs
  JOIN users u ON u.preference_id = rs.preference_id
  WHERE u.id = p_user_id AND rs.is_active = true;

  subject_count := array_length(subject_ids, 1);
  IF subject_count IS NULL OR subject_count = 0 THEN
    RETURN;
  END IF;

  -- Get current total days read
  SELECT COALESCE(SUM(urp.total_completed), 0)
  INTO total_days_read
  FROM user_reading_progress urp
  WHERE urp.user_id = p_user_id
    AND urp.subject_id = ANY(subject_ids);

  -- Generate schedule for the next N days
  FOR i IN 0..(days_ahead - 1) LOOP
    current_subject_index := (total_days_read + i) % subject_count;
    selected_subject_id := subject_ids[current_subject_index + 1];
    selected_subject_name := subject_names[current_subject_index + 1];
    subject_day_sequence := ((total_days_read + i) / subject_count) + 1;

    -- Get reading title for this day (if it exists)
    SELECT dr.title::TEXT INTO reading_title_val
    FROM daily_readings dr
    WHERE dr.subject_id = selected_subject_id
      AND dr.day_sequence = subject_day_sequence
    LIMIT 1;

    RETURN QUERY
    SELECT 
      (total_days_read + i + 1) as day_number,
      selected_subject_id,
      selected_subject_name,
      subject_day_sequence,
      COALESCE(reading_title_val, 'No reading available') as reading_title;
  END LOOP;
END;
$$;

-- ============================================================================
-- STEP 5: Update complete_reading function to work with rotation
-- ============================================================================

-- Updated complete_reading function that properly tracks rotation progress
CREATE OR REPLACE FUNCTION complete_reading(
  p_user_id UUID,
  p_reading_id UUID,
  p_read_time_seconds INTEGER DEFAULT NULL,
  p_was_helpful BOOLEAN DEFAULT NULL,
  p_user_note TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
DECLARE
  v_subject_id UUID;
  v_current_day INTEGER;
  v_total_completed INTEGER;
  v_streak_days INTEGER;
  v_result JSON;
BEGIN
  -- Get subject info from the reading
  SELECT dr.subject_id INTO v_subject_id
  FROM daily_readings dr
  WHERE dr.id = p_reading_id;
  
  IF v_subject_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'Reading not found');
  END IF;
  
  -- Insert or update completion record
  INSERT INTO reading_completions (user_id, reading_id, actual_read_time_seconds, was_helpful, user_note)
  VALUES (p_user_id, p_reading_id, p_read_time_seconds, p_was_helpful, p_user_note)
  ON CONFLICT (user_id, reading_id) DO UPDATE SET
    actual_read_time_seconds = EXCLUDED.actual_read_time_seconds,
    was_helpful = EXCLUDED.was_helpful,
    user_note = EXCLUDED.user_note,
    completed_at = NOW();
  
  -- Update user progress for this specific subject
  INSERT INTO user_reading_progress (user_id, subject_id, current_day, total_completed, last_read_date, started_date)
  VALUES (p_user_id, v_subject_id, 2, 1, CURRENT_DATE, CURRENT_DATE)
  ON CONFLICT (user_id, subject_id) DO UPDATE SET
    current_day = user_reading_progress.current_day + 1,
    total_completed = user_reading_progress.total_completed + 1,
    last_read_date = CURRENT_DATE,
    streak_days = CASE 
      WHEN user_reading_progress.last_read_date = CURRENT_DATE - INTERVAL '1 day' 
      THEN user_reading_progress.streak_days + 1
      WHEN user_reading_progress.last_read_date = CURRENT_DATE 
      THEN user_reading_progress.streak_days
      ELSE 1
    END,
    milestone_30 = CASE WHEN user_reading_progress.total_completed + 1 >= 30 THEN true ELSE user_reading_progress.milestone_30 END,
    milestone_100 = CASE WHEN user_reading_progress.total_completed + 1 >= 100 THEN true ELSE user_reading_progress.milestone_100 END,
    milestone_365 = CASE WHEN user_reading_progress.total_completed + 1 >= 365 THEN true ELSE user_reading_progress.milestone_365 END;
  
  -- Return updated progress
  SELECT json_build_object(
    'success', true,
    'subject_id', v_subject_id,
    'current_day', urp.current_day,
    'total_completed', urp.total_completed,
    'streak_days', urp.streak_days,
    'next_reading_subject', (
      -- Calculate what subject will be next in rotation
      SELECT rs.name
      FROM reading_subjects rs
      JOIN users u ON u.preference_id = rs.preference_id
      WHERE u.id = p_user_id AND rs.is_active = true
      ORDER BY rs.created_at, rs.name
      LIMIT 1 OFFSET (
        (SELECT SUM(urp2.total_completed) FROM user_reading_progress urp2 WHERE urp2.user_id = p_user_id) % 
        (SELECT COUNT(*) FROM reading_subjects rs2 JOIN users u2 ON u2.preference_id = rs2.preference_id WHERE u2.id = p_user_id AND rs2.is_active = true)
      )
    )
  ) INTO v_result
  FROM user_reading_progress urp
  WHERE urp.user_id = p_user_id AND urp.subject_id = v_subject_id;
  
  RETURN v_result;
END;
$$;

-- ============================================================================
-- STEP 6: Test the rotation function
-- ============================================================================

-- Test rotation with minimal test data
DO $$
DECLARE
  test_user_id UUID := 'test-user-001';
  reading_result RECORD;
  schedule_result RECORD;
BEGIN
  RAISE NOTICE '=== TESTING SUBJECT ROTATION ===';
  
  -- Test rotation for days 1-10
  FOR i IN 1..10 LOOP
    RAISE NOTICE 'Day %:', i;
    
    FOR reading_result IN 
      SELECT * FROM get_today_reading(test_user_id, i)
    LOOP
      RAISE NOTICE '  Subject: %, Day Sequence: %, Title: %', 
        reading_result.subject_name, reading_result.day_sequence, reading_result.title;
    END LOOP;
    
    IF NOT FOUND THEN
      RAISE NOTICE '  No reading found for day %', i;
    END IF;
  END LOOP;
  
  RAISE NOTICE '=== ROTATION SCHEDULE (Next 7 days) ===';
  FOR schedule_result IN 
    SELECT * FROM get_rotation_schedule(test_user_id, 7)
  LOOP
    RAISE NOTICE 'Day %: % (Day % of subject)', 
      schedule_result.day_number, schedule_result.subject_name, schedule_result.subject_day_sequence;
  END LOOP;
  
  RAISE NOTICE '=== ALL SUBJECTS CURRENT READINGS ===';
  FOR reading_result IN 
    SELECT * FROM get_today_readings(test_user_id)
  LOOP
    RAISE NOTICE 'Subject: %, Current Day: %, Title: %', 
      reading_result.subject_name, reading_result.day_sequence, reading_result.title;
  END LOOP;
END;
$$;
