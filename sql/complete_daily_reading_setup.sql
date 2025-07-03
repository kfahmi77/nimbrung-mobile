-- COMPLETE DAILY READING SETUP
-- Apply this entire file to your Supabase database
-- This combines both schema and dummy data for convenience

-- ============================================================================
-- SCHEMA SECTION
-- ============================================================================

-- 1. reading_subjects table
CREATE TABLE reading_subjects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon_name VARCHAR(50),
  color_hex VARCHAR(7),
  total_days INTEGER DEFAULT 365,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  preference_id UUID REFERENCES preferences(id)
);

-- 2. daily_readings table
CREATE TABLE daily_readings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subject_id UUID REFERENCES reading_subjects(id),
  day_sequence INTEGER NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  key_insight TEXT,
  tomorrow_hint TEXT,
  read_time_minutes INTEGER DEFAULT 5,
  internal_difficulty INTEGER DEFAULT 1,
  internal_level VARCHAR(20),
  prerequisites_met BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(subject_id, day_sequence)
);

-- 3. user_reading_progress table
CREATE TABLE user_reading_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  subject_id UUID REFERENCES reading_subjects(id),
  current_day INTEGER DEFAULT 1,
  total_completed INTEGER DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  started_date DATE DEFAULT CURRENT_DATE,
  last_read_date DATE,
  milestone_30 BOOLEAN DEFAULT false,
  milestone_100 BOOLEAN DEFAULT false,
  milestone_365 BOOLEAN DEFAULT false,
  UNIQUE(user_id, subject_id)
);

-- 4. reading_completions table
CREATE TABLE reading_completions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  reading_id UUID REFERENCES daily_readings(id),
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actual_read_time_seconds INTEGER,
  was_helpful BOOLEAN,
  user_note TEXT,
  UNIQUE(user_id, reading_id)
);

-- Indexes for better performance
CREATE INDEX idx_daily_readings_subject_day ON daily_readings(subject_id, day_sequence);
CREATE INDEX idx_user_reading_progress_user_subject ON user_reading_progress(user_id, subject_id);
CREATE INDEX idx_reading_completions_user_reading ON reading_completions(user_id, reading_id);
CREATE INDEX idx_reading_subjects_preference ON reading_subjects(preference_id);

-- RPC function to get today's reading for a user
CREATE OR REPLACE FUNCTION get_today_reading(user_id UUID, target_day INTEGER DEFAULT NULL)
RETURNS TABLE (
  reading_id UUID,
  subject_id UUID,
  subject_name VARCHAR,
  day_sequence INTEGER,
  title VARCHAR,
  content TEXT,
  key_insight TEXT,
  tomorrow_hint TEXT,
  read_time_minutes INTEGER,
  created_at TIMESTAMP WITH TIME ZONE,
  is_completed BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dr.id as reading_id,
    dr.subject_id,
    rs.name as subject_name,
    dr.day_sequence,
    dr.title,
    dr.content,
    dr.key_insight,
    dr.tomorrow_hint,
    dr.read_time_minutes,
    dr.created_at,
    (rc.id IS NOT NULL) as is_completed
  FROM daily_readings dr
  JOIN reading_subjects rs ON dr.subject_id = rs.id
  JOIN users u ON u.preference_id = rs.preference_id
  LEFT JOIN user_reading_progress urp ON urp.user_id = u.id AND urp.subject_id = rs.id
  LEFT JOIN reading_completions rc ON rc.user_id = u.id AND rc.reading_id = dr.id
  WHERE u.id = get_today_reading.user_id
    AND rs.is_active = true
    AND dr.day_sequence = COALESCE(target_day, COALESCE(urp.current_day, 1))
  ORDER BY rs.created_at
  LIMIT 1;
END;
$$;

-- RPC function to complete a reading
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
SET search_path = ''
AS $$
DECLARE
  v_subject_id UUID;
  v_current_day INTEGER;
  v_next_day INTEGER;
  v_total_completed INTEGER;
  v_streak_days INTEGER;
  v_result JSON;
BEGIN
  -- Get subject info and current progress
  SELECT dr.subject_id INTO v_subject_id
  FROM daily_readings dr
  WHERE dr.id = p_reading_id;
  
  -- Insert or update completion record
  INSERT INTO reading_completions (user_id, reading_id, actual_read_time_seconds, was_helpful, user_note)
  VALUES (p_user_id, p_reading_id, p_read_time_seconds, p_was_helpful, p_user_note)
  ON CONFLICT (user_id, reading_id) DO UPDATE SET
    actual_read_time_seconds = EXCLUDED.actual_read_time_seconds,
    was_helpful = EXCLUDED.was_helpful,
    user_note = EXCLUDED.user_note,
    completed_at = NOW();
  
  -- Update user progress
  INSERT INTO user_reading_progress (user_id, subject_id, current_day, total_completed, last_read_date)
  VALUES (p_user_id, v_subject_id, 2, 1, CURRENT_DATE)
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
    'current_day', urp.current_day,
    'total_completed', urp.total_completed,
    'streak_days', urp.streak_days
  ) INTO v_result
  FROM user_reading_progress urp
  WHERE urp.user_id = p_user_id AND urp.subject_id = v_subject_id;
  
  RETURN v_result;
END;
$$;

-- RPC function to get reading subjects
CREATE OR REPLACE FUNCTION get_reading_subjects(user_id UUID)
RETURNS TABLE (
  id UUID,
  name VARCHAR,
  description TEXT,
  icon_name VARCHAR,
  color_hex VARCHAR,
  total_days INTEGER,
  is_active BOOLEAN,
  user_progress JSON
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    rs.id,
    rs.name,
    rs.description,
    rs.icon_name,
    rs.color_hex,
    rs.total_days,
    rs.is_active,
    CASE 
      WHEN urp.id IS NOT NULL THEN
        json_build_object(
          'current_day', urp.current_day,
          'total_completed', urp.total_completed,
          'streak_days', urp.streak_days,
          'started_date', urp.started_date,
          'last_read_date', urp.last_read_date
        )
      ELSE NULL
    END as user_progress
  FROM reading_subjects rs
  JOIN users u ON u.preference_id = rs.preference_id
  LEFT JOIN user_reading_progress urp ON urp.user_id = u.id AND urp.subject_id = rs.id
  WHERE u.id = get_reading_subjects.user_id
    AND rs.is_active = true
  ORDER BY rs.created_at;
END;
$$;

-- RPC function to get user progress for a specific subject
CREATE OR REPLACE FUNCTION get_user_progress(p_user_id UUID, p_subject_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_build_object(
    'current_day', COALESCE(urp.current_day, 1),
    'total_completed', COALESCE(urp.total_completed, 0),
    'streak_days', COALESCE(urp.streak_days, 0),
    'started_date', urp.started_date,
    'last_read_date', urp.last_read_date,
    'milestone_30', COALESCE(urp.milestone_30, false),
    'milestone_100', COALESCE(urp.milestone_100, false),
    'milestone_365', COALESCE(urp.milestone_365, false)
  ) INTO v_result
  FROM user_reading_progress urp
  WHERE urp.user_id = p_user_id AND urp.subject_id = p_subject_id;
  
  -- If no progress record exists, return default values
  IF v_result IS NULL THEN
    v_result := json_build_object(
      'current_day', 1,
      'total_completed', 0,
      'streak_days', 0,
      'started_date', NULL,
      'last_read_date', NULL,
      'milestone_30', false,
      'milestone_100', false,
      'milestone_365', false
    );
  END IF;
  
  RETURN v_result;
END;
$$;

-- ============================================================================
-- DUMMY DATA SECTION
-- ============================================================================

-- Insert preferences if not exists
INSERT INTO preferences (id, preferences_name) VALUES
  ('pref-programming-001', 'Programming'),
  ('pref-psychology-002', 'Psikologi'),
  ('pref-business-003', 'Bisnis'),
  ('pref-design-004', 'Desain')
ON CONFLICT (id) DO NOTHING;

-- Insert sample users if not exists
INSERT INTO users (id, email, preference_id, username, fullname) VALUES
  ('user-prog-001', 'programmer@example.com', 'pref-programming-001', 'programmer', 'John Developer'),
  ('user-psych-002', 'psychologist@example.com', 'pref-psychology-002', 'psychologist', 'Sarah Chen'),
  ('user-business-003', 'business@example.com', 'pref-business-003', 'business', 'Mike Entrepreneur'),
  ('user-design-004', 'designer@example.com', 'pref-design-004', 'designer', 'Anna Creative')
ON CONFLICT (id) DO NOTHING;
