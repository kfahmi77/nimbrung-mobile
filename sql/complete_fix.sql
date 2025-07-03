-- COMPLETE FIX - This addresses all potential issues
-- Run this in your Supabase SQL Editor to fix the daily reading setup

-- ============================================================================
-- STEP 1: Re-create all RPC functions (in case they failed before)
-- ============================================================================

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
-- STEP 2: Ensure essential data exists
-- ============================================================================

-- Ensure basic preferences exist
INSERT INTO preferences (id, preferences_name) VALUES
  ('pref-programming-001', 'Programming'),
  ('pref-psychology-002', 'Psikologi'),
  ('pref-business-003', 'Bisnis'),
  ('pref-design-004', 'Desain')
ON CONFLICT (id) DO NOTHING;

-- Ensure we have reading subjects
INSERT INTO reading_subjects (id, name, description, icon_name, color_hex, preference_id, is_active) VALUES
  ('rs-flutter-001', 'Learn Flutter', 'Flutter untuk pemula - Pelajari framework terpopuler untuk mobile development', 'flutter', '#42A5F5', 'pref-programming-001', true),
  ('rs-psychology-001', 'Psikologi Kognitif', 'Memahami cara kerja pikiran manusia dan proses mental', 'psychology', '#9C27B0', 'pref-psychology-002', true)
ON CONFLICT (id) DO NOTHING;

-- Ensure we have daily readings
INSERT INTO daily_readings (id, subject_id, day_sequence, title, content, key_insight, tomorrow_hint) VALUES
  (
    'dr-flutter-001',
    'rs-flutter-001',
    1,
    'Pengenalan Flutter',
    'Flutter adalah framework open-source dari Google untuk membuat aplikasi mobile, web, dan desktop dengan satu codebase. Flutter menggunakan bahasa pemrograman Dart dan memungkinkan developer untuk membuat aplikasi yang fast, beautiful, dan native-compiled.

Key Features Flutter:
1. Single Codebase: Tulis sekali, jalankan di mana saja
2. Hot Reload: Perubahan kode langsung terlihat dalam detik
3. Native Performance: Performa mendekati aplikasi native
4. Rich UI Widgets: Thousands of customizable widgets
5. Growing Community: Dukungan komunitas yang besar',
    'Flutter memungkinkan pengembangan aplikasi cross-platform dengan satu codebase, menghemat waktu dan biaya development.',
    'Besok kita akan mempelajari konsep Widget - building block fundamental dari aplikasi Flutter'
  ),
  (
    'dr-flutter-002',
    'rs-flutter-001',
    2,
    'Widget: Building Blocks Flutter',
    'Di Flutter, semuanya adalah Widget! Widget adalah building block fundamental untuk membuat user interface. Terdapat dua jenis widget utama:

1. StatelessWidget - Widget yang tidak berubah setelah dibuat
2. StatefulWidget - Widget yang dapat berubah state-nya

Widget Tree: Flutter mengorganisir widget dalam bentuk tree structure.',
    'Widget adalah building block fundamental Flutter. Ada StatelessWidget untuk UI statis dan StatefulWidget untuk UI interaktif.',
    'Besok kita akan belajar tentang Layout Widgets untuk mengatur posisi dan ukuran widget'
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 3: Fix existing users to have preferences (if needed)
-- ============================================================================

-- Update users without preferences to have a default preference
UPDATE users 
SET preference_id = 'pref-programming-001' 
WHERE preference_id IS NULL 
AND id IN (
  SELECT id FROM auth.users LIMIT 10  -- Only update first 10 users to be safe
);

-- ============================================================================
-- STEP 4: Test the setup
-- ============================================================================

-- Show functions that were created
SELECT 'Functions created:' as info, routine_name
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('get_today_reading', 'complete_reading', 'get_reading_subjects', 'get_user_progress');

-- Show sample users that should work
SELECT 'Sample users with preferences:' as info, id, email, preference_id
FROM users 
WHERE preference_id IS NOT NULL 
LIMIT 5;

-- Test with first user (replace the UUID with actual user ID from above)
-- SELECT 'Test result:' as info;
-- SELECT * FROM get_today_reading('replace-with-actual-user-id'::uuid);
