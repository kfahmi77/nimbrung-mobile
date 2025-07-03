-- COMPLETE FIX FOR MISSING TABLES
-- Run this script in your Supabase SQL Editor to create all missing tables
-- This script will only create tables that don't already exist

-- ============================================================================
-- CREATE MISSING TABLES FOR DAILY READING FEATURE
-- ============================================================================

-- 1. Create reading_subjects table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS reading_subjects (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon_name VARCHAR(50),
  color_hex VARCHAR(7),
  total_days INTEGER DEFAULT 365,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  preference_id UUID REFERENCES preferences(id)
);

-- 2. Create daily_readings table (if it doesn't exist)  
CREATE TABLE IF NOT EXISTS daily_readings (
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

-- 3. Create user_reading_progress table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS user_reading_progress (
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

-- 4. Create reading_completions table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS reading_completions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  reading_id UUID REFERENCES daily_readings(id),
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  actual_read_time_seconds INTEGER,
  was_helpful BOOLEAN,
  user_note TEXT,
  UNIQUE(user_id, reading_id)
);

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE (only if they don't exist)
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_daily_readings_subject_day ON daily_readings(subject_id, day_sequence);
CREATE INDEX IF NOT EXISTS idx_user_reading_progress_user_subject ON user_reading_progress(user_id, subject_id);
CREATE INDEX IF NOT EXISTS idx_reading_completions_user_reading ON reading_completions(user_id, reading_id);
CREATE INDEX IF NOT EXISTS idx_reading_subjects_preference ON reading_subjects(preference_id);

-- ============================================================================
-- ADD ESSENTIAL SAMPLE DATA
-- ============================================================================

-- Add sample reading subjects (only if they don't exist)
INSERT INTO reading_subjects (name, description, icon_name, color_hex, preference_id) 
SELECT 'Learn Flutter', 'Flutter untuk pemula - Pelajari framework terpopuler untuk mobile development', 'flutter', '#42A5F5', 
   (SELECT id FROM preferences WHERE preferences_name = 'Programming' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM reading_subjects WHERE name = 'Learn Flutter');

INSERT INTO reading_subjects (name, description, icon_name, color_hex, preference_id) 
SELECT 'Psikologi Kognitif', 'Memahami cara kerja pikiran manusia dan proses mental', 'psychology', '#9C27B0',
   (SELECT id FROM preferences WHERE preferences_name = 'Psikologi' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM reading_subjects WHERE name = 'Psikologi Kognitif');

-- Add sample daily readings for Flutter
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) 
SELECT 
  (SELECT id FROM reading_subjects WHERE name = 'Learn Flutter' LIMIT 1),
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
WHERE NOT EXISTS (
  SELECT 1 FROM daily_readings dr 
  JOIN reading_subjects rs ON dr.subject_id = rs.id 
  WHERE rs.name = 'Learn Flutter' AND dr.day_sequence = 1
);

INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) 
SELECT 
  (SELECT id FROM reading_subjects WHERE name = 'Learn Flutter' LIMIT 1),
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
WHERE NOT EXISTS (
  SELECT 1 FROM daily_readings dr 
  JOIN reading_subjects rs ON dr.subject_id = rs.id 
  WHERE rs.name = 'Learn Flutter' AND dr.day_sequence = 2
);

-- Add sample daily readings for Psychology
INSERT INTO daily_readings (subject_id, day_sequence, title, content, key_insight, tomorrow_hint) 
SELECT 
  (SELECT id FROM reading_subjects WHERE name = 'Psikologi Kognitif' LIMIT 1),
  1,
  'Pengantar Psikologi Kognitif',
  'Psikologi kognitif adalah cabang dari psikologi yang mempelajari proses mental internal seperti persepsi, memori, pemikiran, dan pengambilan keputusan. Bidang ini berkembang pesat sejak "revolusi kognitif" pada tahun 1950-an.

Fokus Utama Psikologi Kognitif:
1. Persepsi - Bagaimana kita menginterpretasi informasi sensorik
2. Memori - Proses encoding, storage, dan retrieval informasi
3. Perhatian - Bagaimana kita fokus pada stimulus tertentu
4. Bahasa - Pemahaman dan produksi bahasa
5. Problem Solving - Cara menyelesaikan masalah
6. Decision Making - Proses pengambilan keputusan',
  'Psikologi kognitif mempelajari proses mental internal seperti persepsi, memori, dan pemikiran untuk memahami bagaimana manusia memproses informasi.',
  'Besok kita akan mendalami sistem memori manusia dan bagaimana informasi disimpan dan diambil'
WHERE NOT EXISTS (
  SELECT 1 FROM daily_readings dr 
  JOIN reading_subjects rs ON dr.subject_id = rs.id 
  WHERE rs.name = 'Psikologi Kognitif' AND dr.day_sequence = 1
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check that all tables now exist
SELECT 'TABLES CREATED SUCCESSFULLY' as status;

SELECT 
  table_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = t.table_name AND table_schema = 'public') 
    THEN '✅ EXISTS' 
    ELSE '❌ MISSING' 
  END as status
FROM (VALUES 
  ('reading_subjects'),
  ('daily_readings'), 
  ('user_reading_progress'),
  ('reading_completions')
) AS t(table_name);

-- Check data counts
SELECT 'reading_subjects' as table_name, COUNT(*) as row_count FROM reading_subjects
UNION ALL
SELECT 'daily_readings', COUNT(*) FROM daily_readings;

-- Final test - this should now work:
SELECT 'READY TO TEST' as message;
SELECT 'Run this command to test:' as instruction;
SELECT 'SELECT * FROM get_today_reading(''23a5b62e-8c35-440e-af6e-e033577aa0b4''::uuid);' as test_command;
