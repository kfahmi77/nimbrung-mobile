-- FIXED RPC FUNCTIONS - Apply this to your existing Supabase database
-- This fixes the schema path issue that was causing the "relation does not exist" error

-- ============================================================================
-- STEP 1: Drop existing functions (if they exist)
-- ============================================================================
DROP FUNCTION IF EXISTS get_today_reading(UUID, INTEGER);
DROP FUNCTION IF EXISTS complete_reading(UUID, UUID, INTEGER, BOOLEAN, TEXT);
DROP FUNCTION IF EXISTS get_reading_subjects(UUID);
DROP FUNCTION IF EXISTS get_user_progress(UUID, UUID);

-- ============================================================================
-- STEP 2: Create fixed RPC functions with proper schema references
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
  FROM public.daily_readings dr
  JOIN public.reading_subjects rs ON dr.subject_id = rs.id
  JOIN public.users u ON u.preference_id = rs.preference_id
  LEFT JOIN public.user_reading_progress urp ON urp.user_id = u.id AND urp.subject_id = rs.id
  LEFT JOIN public.reading_completions rc ON rc.user_id = u.id AND rc.reading_id = dr.id
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
  FROM public.daily_readings dr
  WHERE dr.id = p_reading_id;
  
  -- Insert or update completion record
  INSERT INTO public.reading_completions (user_id, reading_id, actual_read_time_seconds, was_helpful, user_note)
  VALUES (p_user_id, p_reading_id, p_read_time_seconds, p_was_helpful, p_user_note)
  ON CONFLICT (user_id, reading_id) DO UPDATE SET
    actual_read_time_seconds = EXCLUDED.actual_read_time_seconds,
    was_helpful = EXCLUDED.was_helpful,
    user_note = EXCLUDED.user_note,
    completed_at = NOW();
  
  -- Update user progress
  INSERT INTO public.user_reading_progress (user_id, subject_id, current_day, total_completed, last_read_date)
  VALUES (p_user_id, v_subject_id, 2, 1, CURRENT_DATE)
  ON CONFLICT (user_id, subject_id) DO UPDATE SET
    current_day = public.user_reading_progress.current_day + 1,
    total_completed = public.user_reading_progress.total_completed + 1,
    last_read_date = CURRENT_DATE,
    streak_days = CASE 
      WHEN public.user_reading_progress.last_read_date = CURRENT_DATE - INTERVAL '1 day' 
      THEN public.user_reading_progress.streak_days + 1
      WHEN public.user_reading_progress.last_read_date = CURRENT_DATE 
      THEN public.user_reading_progress.streak_days
      ELSE 1
    END,
    milestone_30 = CASE WHEN public.user_reading_progress.total_completed + 1 >= 30 THEN true ELSE public.user_reading_progress.milestone_30 END,
    milestone_100 = CASE WHEN public.user_reading_progress.total_completed + 1 >= 100 THEN true ELSE public.user_reading_progress.milestone_100 END,
    milestone_365 = CASE WHEN public.user_reading_progress.total_completed + 1 >= 365 THEN true ELSE public.user_reading_progress.milestone_365 END;
  
  -- Return updated progress
  SELECT json_build_object(
    'success', true,
    'current_day', urp.current_day,
    'total_completed', urp.total_completed,
    'streak_days', urp.streak_days
  ) INTO v_result
  FROM public.user_reading_progress urp
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
  FROM public.reading_subjects rs
  JOIN public.users u ON u.preference_id = rs.preference_id
  LEFT JOIN public.user_reading_progress urp ON urp.user_id = u.id AND urp.subject_id = rs.id
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
  FROM public.user_reading_progress urp
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
-- STEP 3: Add sample data to your existing tables
-- ============================================================================

-- Add sample reading subjects (only if needed)
INSERT INTO public.reading_subjects (name, description, icon_name, color_hex, preference_id) VALUES
  ('Learn Flutter', 'Flutter untuk pemula - Pelajari framework terpopuler untuk mobile development', 'flutter', '#42A5F5', 
   (SELECT id FROM public.preferences WHERE preferences_name = 'Programming' LIMIT 1)),
  ('Psikologi Kognitif', 'Memahami cara kerja pikiran manusia dan proses mental', 'psychology', '#9C27B0',
   (SELECT id FROM public.preferences WHERE preferences_name = 'Psikologi' LIMIT 1))
ON CONFLICT (name) DO NOTHING;

-- Add sample daily readings
INSERT INTO public.daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) VALUES
  (
    (SELECT id FROM public.reading_subjects WHERE name = 'Learn Flutter' LIMIT 1),
    1,
    'Pengenalan Flutter',
    'Flutter adalah framework open-source dari Google untuk membuat aplikasi mobile, web, dan desktop dengan satu codebase. Flutter menggunakan bahasa pemrograman Dart dan memungkinkan developer untuk membuat aplikasi yang fast, beautiful, dan native-compiled.

Key Features Flutter:
1. Single Codebase: Tulis sekali, jalankan di mana saja
2. Hot Reload: Perubahan kode langsung terlihat dalam detik
3. Native Performance: Performa mendekati aplikasi native
4. Rich UI Widgets: Thousands of customizable widgets
5. Growing Community: Dukungan komunitas yang besar

Flutter telah digunakan oleh perusahaan besar seperti Google, Alibaba, BMW, dan banyak lagi. Dengan Flutter, Anda dapat mengembangkan aplikasi untuk iOS, Android, web, Windows, macOS, dan Linux.',
    'Flutter memungkinkan pengembangan aplikasi cross-platform dengan satu codebase, menghemat waktu dan biaya development.',
    'Besok kita akan mempelajari konsep Widget - building block fundamental dari aplikasi Flutter'
  ),
  (
    (SELECT id FROM public.reading_subjects WHERE name = 'Learn Flutter' LIMIT 1),
    2,
    'Widget: Building Blocks Flutter',
    'Di Flutter, semuanya adalah Widget! Widget adalah building block fundamental untuk membuat user interface. Terdapat dua jenis widget utama:

1. StatelessWidget
- Widget yang tidak berubah setelah dibuat
- Cocok untuk UI yang statis
- Contoh: Text, Icon, Image

2. StatefulWidget  
- Widget yang dapat berubah state-nya
- Cocok untuk UI yang interaktif
- Contoh: Button, Form, Animation

Widget Tree:
Flutter mengorganisir widget dalam bentuk tree structure. Parent widget mengandung child widget, dan setiap widget dapat memiliki properties yang mengontrol appearance dan behavior.',
    'Widget adalah building block fundamental Flutter. Ada StatelessWidget untuk UI statis dan StatefulWidget untuk UI interaktif.',
    'Besok kita akan belajar tentang Layout Widgets untuk mengatur posisi dan ukuran widget'
  ),
  (
    (SELECT id FROM public.reading_subjects WHERE name = 'Psikologi Kognitif' LIMIT 1),
    1,
    'Pengantar Psikologi Kognitif',
    'Psikologi kognitif adalah cabang dari psikologi yang mempelajari proses mental internal seperti persepsi, memori, pemikiran, dan pengambilan keputusan. Bidang ini berkembang pesat sejak "revolusi kognitif" pada tahun 1950-an.

Fokus Utama Psikologi Kognitif:
1. Persepsi - Bagaimana kita menginterpretasi informasi sensorik
2. Memori - Proses encoding, storage, dan retrieval informasi
3. Perhatian - Bagaimana kita fokus pada stimulus tertentu
4. Bahasa - Pemahasan dan produksi bahasa
5. Problem Solving - Cara menyelesaikan masalah
6. Decision Making - Proses pengambilan keputusan',
    'Psikologi kognitif mempelajari proses mental internal seperti persepsi, memori, dan pemikiran untuk memahami bagaimana manusia memproses informasi.',
    'Besok kita akan mendalami sistem memori manusia dan bagaimana informasi disimpan dan diambil'
  )
ON CONFLICT (subject_id, day_sequence) DO NOTHING;

-- ============================================================================
-- STEP 4: Test the function
-- ============================================================================

-- You can test with your user ID:
-- SELECT * FROM get_today_reading('23a5b62e-8c35-440e-af6e-e033577aa0b4'::uuid);

SELECT '=== RPC FUNCTIONS FIXED AND READY ===' as status;
SELECT 'Run the test query above with your user ID to verify' as next_step;
